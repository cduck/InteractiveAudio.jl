"""
    AbstractAudioGenerator

Interface for streaming audio generators.  Concrete types must implement
`reset!`, `has_samples`, and `next_samples!`.
"""
abstract type AbstractAudioGenerator end

"""
    NullAudioGenerator

An audio generator containing no audio samples.
"""
struct NullAudioGenerator <: AbstractAudioGenerator end
reset!(gen::NullAudioGenerator) = nothing
has_samples(gen::NullAudioGenerator, sample_rate::Float64) = false
function next_samples!(gen::NullAudioGenerator, max_n::Int,
                       sample_rate::Float64)
    @assert(false, "NullAudioGenerator has no samples")
end
