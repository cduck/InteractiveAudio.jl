"""
    BackgroundPlayer(stream::PortAudioStream[, src::AbstractAudioGenerator];
                     block_size=undef)

The object that manages a background audio thread.

Create one instance per audio stream.  Replace or modify the `src` field while
audio is playing with `lock_player` for thread safety.

Functions: `play`, `pause`, `is_playing`, `lock_player`, `finalize`
"""
mutable struct BackgroundPlayer
    _lock::ReentrantLock
    _play_lock::ReentrantLock
    _play_sync::Threads.Condition
    _is_playing::Bool
    stream::PortAudioStream
    src::AbstractAudioGenerator
    block_size::Int
    sample_rate::Float64

    function BackgroundPlayer(stream::PortAudioStream; block_size=undef)
        BackgroundPlayer(
            stream,
            NullAudioGenerator();
            block_size=block_size,
        )
    end
    function BackgroundPlayer(
            stream::PortAudioStream,
            src::AbstractAudioGenerator
            ; block_size=undef)
        # Ensure Julia has multiple threads
        @assert(Threads.nthreads() >= 2,
            "BackgroundPlayer requires its own thread "
            *"(start julia with `\$ JULIA_NUM_THREADS=4 julia)`")
        # Init
        play = src != NullAudioGenerator()  # Auto start playing if not null
        if block_size == undef
            block_size = size(stream.sink.chunkbuf)[2]
        end
        player = new(
            ReentrantLock(),
            ReentrantLock(),
            Threads.Condition(),
            play,
            stream,
            src,
            block_size,
            stream.samplerate,
        )
        # Start background task
        ref = WeakRef(player)
        stop = Threads.Atomic{Bool}(false)
        task = Threads.@spawn _background_play(ref, stop)
        # Register finalizer
        finalizer(player) do p
            # TODO: Check this runs (ensure no memory leaks)
            stop[] = true
            lock(p._play_sync.lock) do
                notify(p._play_sync)
            end
        end
        player
    end
end

function Base.show(io::IO, p::BackgroundPlayer)
    write(io, "BackgroundPlayer "
          *"($(is_playing(p) ? "playing" : "paused"), "
          *"block_size=$(p.block_size))\n"
          *"  Stream: $(p.stream)\n\n  Src: $(p.src)")
end

function _async_println(args...)
    @async begin
        println(args...)
        flush(stdout)
    end
end

"""Run with Threads.@spawn by BackgroundPlayer."""
function _background_play(ref::WeakRef, stop::Threads.Atomic{Bool})
    try
        while true
            stop[] && break
            quit, play, play_sync = _background_play_inner(ref)
            quit && break
            play || lock(play_sync.lock) do
                wait(play_sync)  # Wait until allowed to play
            end
        end
    catch e
        _async_println(stderr, "background player error: $e")
    end
end
function _background_play_inner(ref::WeakRef)
    p::Union{Nothing, BackgroundPlayer} = ref.value
    p == nothing && return true, false, nothing
    player = p
    p = nothing
    samples = Ref{Any}(nothing)
    play = lock(player._play_lock) do
        play = lock(player._lock) do
            play = player._is_playing
            play || return play
            try
                src = player.src
                rate = player.sample_rate
                if !has_samples(src, rate)
                    player._is_playing = false
                    return false
                end
                bs = player.block_size
                samples[] = next_samples!(src, bs, rate)
                @assert(size(samples[])[1] <= bs,
                    "too many samples from source "
                    *"($(size(samples[])[1]) > $bs)")
            catch e
                _async_println(
                    stderr, "background error while playing $(player.src): $e")
                player._is_playing = false
                player = nothing
                return false
            end
            play
        end
        play && write(player.stream, samples[])
        play
    end
    play_sync = player._play_sync
    player = nothing  # Release reference while waiting
    false, play, play_sync
end

"""
    lock_player(player::BackgroundPlayer) do
        # Modify or replace player.src while audio is playing.
        # ...
    end
"""
function lock_player(f::Function, player::BackgroundPlayer)
    lock(f, player._lock)
end

function pause(player::BackgroundPlayer)
    lock(player._play_lock) do
        player._is_playing = false
    end
    nothing
end

function play(player::BackgroundPlayer, src::AbstractAudioGenerator)
    lock_player(player) do
        player.src = src
        play(player)
    end
end
function play(player::BackgroundPlayer)
    lock(player._lock) do
        player._is_playing = true
        lock(player._play_sync.lock) do
            notify(player._play_sync)
        end
    end
    nothing
end

function is_playing(player::BackgroundPlayer)::Bool
    lock(player._lock) do
        player._is_playing
    end
end
