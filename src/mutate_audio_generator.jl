"""
    MutateAudioGenerator

An audio generator that wraps another.  It mutates its audio with the given
function.  This is useful for applying an envelope or distortion to a signal.

# Example
```julia
gen = MutateGen(
    SineAudioGenerator(0, 0.5, 400),
    (times, samples) -> (samples .* (1 .- exp.(times.*-80))
                                 .* exp.(times.*-3))
)
```
"""
mutable struct MutateAudioGenerator <: AbstractAudioGenerator
    gen::AbstractAudioGenerator
    env::Function  # Applies the envelope to the given (times, samples)
    _t::Float64
    MutateAudioGenerator(gen, env) = new(gen, env, 0.)
end

function reset!(gen::MutateAudioGenerator)
    reset!(gen.gen)
    gen._t = 0.
    nothing
end
function has_samples(gen::MutateAudioGenerator, sample_rate::Float64)
    has_samples(gen.gen, sample_rate)
end
function next_samples!(gen::MutateAudioGenerator, max_n::Int,
                       sample_rate::Float64)
    times = StepRangeLen(gen._t, 1/sample_rate, max_n)
    gen._t += max_n / sample_rate
    samples = next_samples!(gen.gen, max_n, sample_rate)
    gen.env(times, samples)
end
