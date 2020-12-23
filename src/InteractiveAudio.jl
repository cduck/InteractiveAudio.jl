"""
A [Julia](https://julialang.org/) threaded audio output interface to [PortAudio](https://github.com/JuliaAudio/PortAudio.jl) that allows dynamic real-time changes to your audio code while it is playing.  This is useful for quickly iterating your code in Julia's REPL or a [Jupyter](https://jupyter.org/) [notebook](https://github.com/JuliaLang/IJulia.jl).

See [documentation and examples](https://github.com/cduck/InteractiveAudio.jl).
"""
module InteractiveAudio

using Base.Threads
using Base: lock, unlock, trylock, islocked, ReentrantLock

using SampledSignals
using PortAudio

export BackgroundPlayer, play, pause, is_playing, lock_player
export AbstractAudioGenerator, NullAudioGenerator, SampleAudioGenerator,
    SineAudioGenerator, SumAudioGenerator, MutateAudioGenerator


include("audio_generator.jl")
include("background_player.jl")
include("sample_audio_generator.jl")
include("sine_audio_generator.jl")
include("sum_audio_generator.jl")
include("mutate_audio_generator.jl")


end
