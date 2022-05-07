using OptiX
using Documenter

DocMeta.setdocmeta!(OptiX, :DocTestSetup, :(using OptiX); recursive=true)

makedocs(;
    modules=[OptiX],
    authors="Roger Mateer <rogermateer@gmail.com> and contributors",
    repo="https://github.com/rogermateer/OptiX.jl/blob/{commit}{path}#{line}",
    sitename="OptiX.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://rogermateer.github.io/OptiX.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/rogermateer/OptiX.jl",
    devbranch="main",
)
