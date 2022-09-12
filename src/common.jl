using Reexport
@reexport using JSON3
@reexport using GZip

exampleDailyFile = "../data/2022/05/27/AlphaVantage.TIME_SERIES_DAILY.AAPL.2022-05-27.json.gz"

"""

Find all relevant files in my data lake

"""
function findFiles(dataLakePath::String,pattern::String)::Vector{String}
    allFiles = []
    for (root, dirs, files) in walkdir(dataLakePath)
        for file in files
            push!(allFiles,joinpath(root,file))
        end
    end
    return filter(x->occursin(pattern,x),allFiles)
end
function findFiles(dataLakePath::String,vendor::String,call::String)::Vector{String}
    return findFiles(dataLakePath,"$(vendor).$(call)")
end
function findFiles(dataLakePath::String,vendor::String,call::String,ticker::String)::Vector{String}
    return findFiles(dataLakePath,"$(vendor).$(call).$(ticker)")
end
export findFiles

"""

Read the contents of a gzipped json file into a JSON3 Object or
JSON3.Array, as appropriate

"""
function readGZippedJson(filePath::String)::Union{JSON3.Object,JSON3.Array}
    return GZip.open(filePath) do io
        JSON3.read(io)
    end
end
export readGZippedJson

