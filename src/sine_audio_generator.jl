"""
    SineAudioGenerator

An audio generator for a simple sine wave.  The waveform will be continuous even
if the rate (frequency) is modified during playback.
"""
mutable struct SineAudioGenerator <: AbstractAudioGenerator
    phase::Float64
    amp::Float64
    rate::Float64
end

function reset!(gen::SineAudioGenerator)
    gen.phase = 0
    nothing
end
function has_samples(gen::SineAudioGenerator, sample_rate::Float64)
    true
end
function next_samples!(gen::SineAudioGenerator, max_n::Int,
                       sample_rate::Float64)
    dphase = gen.rate / sample_rate
    pi2 = 2*pi
    samples = zeros(Float64, max_n, 2)
    p = gen.phase
    for i in 1:max_n
        samples[i, 1] = samples[i, 2] = gen.amp * sin(pi2*p)
        p += dphase
    end
    gen.phase = p
    samples
end
