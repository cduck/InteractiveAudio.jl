"""
A [Julia](https://julialang.org/) threaded audio output interface to [PortAudio](https://github.com/JuliaAudio/PortAudio.jl) that allows dynamic real-time changes to your audio code while it is playing.  This is useful for quickly iterating your code in Julia's REPL or a [Jupyter](https://jupyter.org/) [notebook](https://github.com/JuliaLang/IJulia.jl).

See [documentation and examples](https://github.com/cduck/InteractiveAudio.jl).
"""
module InteractiveAudio


include("audio_generator.jl")
include("background_player.jl")


end
