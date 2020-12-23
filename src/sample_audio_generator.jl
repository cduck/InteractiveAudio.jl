"""
    SampleAudioGenerator

An audio generator that plays back a sample at a fixed sample rate.  The sample
can optionally be looped.
"""
mutable struct SampleAudioGenerator <: AbstractAudioGenerator
    sample_rate::Float64
    samples
    looped::Bool
    _state::Int
    function SampleAudioGenerator(sample_rate::Float64, samples;
                                   looped::Bool=false)
        new(sample_rate, samples, looped, 1)
    end
end

function reset!(gen::SampleAudioGenerator)
    gen._state = 1
end
function has_samples(gen::SampleAudioGenerator, sample_rate::Float64)
    @assert(sample_rate == gen.sample_rate, "sample rate mismatch")
    gen.looped || gen._state <= size(gen.samples)[1]
end
function next_samples!(gen::SampleAudioGenerator, max_n::Int,
                       sample_rate::Float64)
    @assert(sample_rate == gen.sample_rate, "sample rate mismatch")
    first = gen._state
    last = min(first+max_n-1, size(gen.samples)[1])
    gen._state = last+1
    r = gen.samples[first:last, :]
    gen.looped || return r
    while size(r)[1] < max_n
        first = gen._state = 1
        last = min(first+max_n-1-size(r)[1], size(gen.samples)[1])
        gen._state = last+1
        r = [r; gen.samples[first:last, :]]
    end
    r
end
