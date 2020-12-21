# InteractiveAudio

A [Julia](https://julialang.org/) threaded audio output interface to [PortAudio](https://github.com/JuliaAudio/PortAudio.jl) that allows dynamic real-time changes to your audio code while it is playing.  This is useful for quickly iterating your code in Julia's REPL or a [Jupyter](https://jupyter.org/) [notebook](https://github.com/JuliaLang/IJulia.jl).

See also: [SampledSignals.jl](https://github.com/JuliaAudio/SampledSignals.jl),
[LibSndFile.jl](https://github.com/JuliaAudio/LibSndFile.jl),
[FastRepl.jl](https://github.com/cduck/FastRepl.jl),
and [IJulia.jl fork](https://github.com/cduck/IJulia.jl)


# Install

Install InteractiveAudio with Julia's package manager:

Start julia in [command mode](https://docs.julialang.org/en/v1/stdlib/Pkg/)
(type a right bracket `]` after starting julia from the command line)
or enter each line starting with a `]` in a separate Jupyter cell.
```bash
julia
] add https://github.com/JuliaAudio/PortAudio.jl
] add InteractiveAudio
```
Optional:
```bash
] add LibSndFile
] add https://github.com/cduck/FastRepl.jl
] add https://github.com/cduck/IJulia.jl
```


# Examples

```julia
...
```
