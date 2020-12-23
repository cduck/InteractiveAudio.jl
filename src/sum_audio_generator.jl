"""
    SumAudioGenerator

An audio generator used to combine (sum) multiple other sources.
"""
mutable struct SumAudioGenerator <: AbstractAudioGenerator
    generators::Vector{AbstractAudioGenerator}
end

function reset!(gen::SumAudioGenerator)
    for g in gen.generators
        reset!(g)
    end
    nothing
end
function has_samples(gen::SumAudioGenerator, sample_rate::Float64)
    any(
        has_samples(g, sample_rate)
        for g in gen.generators
    )
end
function next_samples!(gen::SumAudioGenerator, max_n::Int,
                       sample_rate::Float64)
    samples = zeros(Float64, max_n, 2)
    max_len = 0
    for g in gen.generators
        s = next_samples!(g, max_n, sample_rate)
        len = size(s)[1]
        samples[1:len, :] .+= s
        max_len = max(max_len, len)
    end
    samples[1:max_len]
end
