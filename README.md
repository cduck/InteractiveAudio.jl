# InteractiveAudio

A [Julia](https://julialang.org/) threaded audio output interface to [PortAudio](https://github.com/JuliaAudio/PortAudio.jl) that allows dynamic real-time changes to your audio code while it is playing.  This is useful for quickly iterating your code in Julia's REPL or a [Jupyter](https://jupyter.org/) [notebook](https://github.com/JuliaLang/IJulia.jl).

See also: [SampledSignals.jl](https://github.com/JuliaAudio/SampledSignals.jl),
[LibSndFile.jl](https://github.com/JuliaAudio/LibSndFile.jl),
[FastRepl.jl](https://github.com/cduck/FastRepl.jl),
and [IJulia.jl (fork)](https://github.com/cduck/IJulia.jl)


# Install

Install InteractiveAudio with Julia's package manager:

Start julia in [command mode](https://docs.julialang.org/en/v1/stdlib/Pkg/)
(type a right bracket `]` after starting julia from the command line)
or enter each line starting with a `]` in a separate Jupyter cell.
```bash
julia
] add https://github.com/JuliaAudio/PortAudio.jl
] add https://github.com/cduck/InteractiveAudio.jl
```
Optional:
```bash
] add LibSndFile
] add https://github.com/cduck/FastRepl.jl
] add https://github.com/cduck/IJulia.jl
```


# Examples

### Setup (run this first)
```julia
# Imports
using SampledSignals
using PortAudio
using LibSndFile
using FileIO: load, save, loadstreaming, savestreaming
using InteractiveAudio

display(PortAudio.devices())  # List audio devices
stream = PortAudioStream(0, 2)  # Stereo output, no input, default device
player = BackgroundPlayer(stream)  # Start background audio thread
```

### Play a WAV file
```julia
snd = load("test-input.wav")
sg = SampleAudioGenerator(48000., snd, looped=true)
play(player, sg)
```
```julia
# Pause
pause(player)
```

### Play a C Major Chord
```julia
C4 = 220*2^(3/12)
E4 = C4*2^(4/12)
G4 = C4*2^(7/12)
gen = MutateAudioGenerator(
    # C Major Chord
    SumAudioGenerator([
        SineAudioGenerator(0, 0.5, C4),
        SineAudioGenerator(0, 0.5, E4),
        SineAudioGenerator(0, 0.5, G4),
    ]),
    # Envelope to fade the note
    (times, samples) -> (samples .* (1 .- exp.(times.*-80)) .* exp.(times.*-2))
)
play(player, gen)
```

#### Save the C Major Chord
```julia
function save_samples(gen, dt, sample_rate=48000)
    max_n = round(Int, dt*sample_rate)
    times = StepRangeLen(0, 1/sample_rate, max_n)
    samples = InteractiveAudio.next_samples!(
                gen, max_n, sample_rate*1.)
    waveform = SampleBuf(samples, sample_rate)
    save("c-major.wav", waveform)
end

lock_player(player) do
    InteractiveAudio.reset!(gen)
    save_samples(gen, 2, 48000)
end
```

#### Visualize the C Major Chord
```julia
using Plots  # Requires the Plots package (add Plots)

function plot_samples(gen, dt, sample_rate=48000)
    max_n = round(Int, dt*sample_rate)
    times = StepRangeLen(0, 1/sample_rate, max_n)
    samples = InteractiveAudio.next_samples!(
                gen, max_n, sample_rate*1.)
    display(plot(times, samples))
end

lock_player(player) do
    InteractiveAudio.reset!(gen)
    plot_samples(gen, 1, 48000)
end
```

### Custom Synthesizer Type
```julia
mutable struct MyGenerator <: AbstractAudioGenerator
    phase::Float64
    amp::Float64
    rate::Float64
end

function InteractiveAudio.reset!(gen::MyGenerator)
    gen.phase = 0  # Reset to time=0
    nothing
end
function InteractiveAudio.has_samples(
        gen::MyGenerator, sample_rate::Float64)
    true
end
function InteractiveAudio.next_samples!(
        gen::MyGenerator, max_n::Int, sample_rate::Float64)
    samples = zeros(Float64, max_n, 2)
    for i in 1:max_n
        # Distorted sine wave
        samples[i, 1] = samples[i, 2] = gen.amp * sin(2*pi*gen.phase) ^ 3
        gen.phase += gen.rate / sample_rate
    end
    samples
end
```
```julia
# Middle C Note
C4 = 220*2^(3/12)
gen = MyGenerator(0, 0.5, C4)

# Visualize
plot_samples(gen, 1/50, 48000)

# Play
InteractiveAudio.reset!(gen)
play(player, gen)
```

### Interactive Audio with [Widgets](https://github.com/JuliaGizmos/Interact.jl)
```julia
# Requires the Interact package (add WebIO Interact)
# Documentation: https://github.com/JuliaGizmos/Interact.jl
#using WebIO; WebIO.install_jupyter_labextension()  # Setup WebIO
using Interact

gen = SumAudioGenerator([  # Two sine waves
    SineAudioGenerator(0, 0.5, 500),
    SineAudioGenerator(0, 0.5, 500),
])
play(player, gen)

@manipulate for f=0:0.1:1000, a=0:0.01:1, f2=0:0.1:1000, a2=0:0.01:1
    # Update the generator parameters when the sliders are adjusted
    lock_player(player) do
        #InteractiveAudio.reset!(gen)
        gen.generators[1].rate = f
        gen.generators[1].amp = a
        gen.generators[2].rate = f2
        gen.generators[2].amp = a2
    end
end
```
