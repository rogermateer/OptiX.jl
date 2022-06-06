module OptiX
using Reexport
@reexport using GZip
@reexport using JSON3
@reexport using Dates
import StructTypes

"""

Find all relevant files in my data lake

"""
function findFiles(dataLakePath::String,vendor::String,call::String,ticker::String)::Vector{String}
    allFiles = []
    for (root, dirs, files) in walkdir(dataLakePath)
        for file in files
            push!(allFiles,joinpath(root,file))
        end
    end
    return filter(x->occursin("$(vendor).$(call).$(ticker)",x),allFiles)
end
export findFiles

"""

Read the contents of a gzipped json file into a JSON3 Object

"""
function readGZippedJson(filePath::String)::JSON3.Object
    return GZip.open(filePath) do io
        JSON3.read(io)
    end
end
export readGZippedJson

"""

Internal representation of generic time series data

"""
mutable struct OhlcvBar
    timestamp::DateTime
    open::Float64
    high::Float64
    low::Float64
    close::Float64
    volume::Int64
    OhlcvBar() = new()
end
export OhlcvBar

StructTypes.StructType(::Type{OhlcvBar}) = begin
    StructTypes.Mutable()
end

"""

Convert an AlphaVantage TIME_SERIES_DAILY bar into our generic
internal form

"""
function convertAlphaVantageTimeSeriesDailyBar(key::Symbol,value::JSON3.Object)::OhlcvBar
    return JSON3.read("""{
    "timestamp":"$(key)",
    "open":$(value["1. open"]),
    "high":$(value["2. high"]),
    "low":$(value["3. low"]),
    "close":$(value["4. close"]),
    "volume":$(value["5. volume"])
}""",OhlcvBar)
end
export convertAlphaVantageTimeSeriesDailyBar

"""

Convert all bars of an AlphaVantage TIME_SERIES_DAILY call into a
Vector of bars of our generic internal form

"""
function convertAlphaVantageTimeSeriesDaily(json::JSON3.Object)::Vector{OhlcvBar}
    bars = OhlcvBar[]
    data = json["Time Series (Daily)"]
    for key in sort(collect(keys(data)))
        push!(bars,convertAlphaVantageTimeSeriesDailyBar(key,data[key]))
    end
    return bars
end
export convertAlphaVantageTimeSeriesDaily

end # module
