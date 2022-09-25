using Reexport
@reexport using Dates
import StructTypes

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

"""

Convert an AlphaVantage TIME_SERIES_INTRADAY bar into our generic
internal form

"""
function convertAlphaVantageTimeSeriesIntradayBar(key::Symbol,value::JSON3.Object)::OhlcvBar
    return JSON3.read("""{
    "timestamp":"$(DateTime(String(key),DateFormat("y-m-d H:M:S")))",
    "open":$(value["1. open"]),
    "high":$(value["2. high"]),
    "low":$(value["3. low"]),
    "close":$(value["4. close"]),
    "volume":$(value["5. volume"])
}""",OhlcvBar)
end
export convertAlphaVantageTimeSeriesIntradayBar

"""

Convert all bars of an AlphaVantage TIME_SERIES_INTRADAY call into a
Vector of bars of our generic internal form

"""
function convertAlphaVantageTimeSeriesIntraday(json::JSON3.Object)::Vector{OhlcvBar}
    bars = OhlcvBar[]
    data = json["Time Series (1min)"]
    for key in sort(collect(keys(data)))
        push!(bars,convertAlphaVantageTimeSeriesIntradayBar(key,data[key]))
    end
    return bars
end
export convertAlphaVantageTimeSeriesIntraday

"""

Create a range of timestamps given a start, stop, and step (eg Dates.Day(1))

"""
function createTimestamps(start::DateTime,stop::DateTime,step::Period)::Vector{DateTime}
    return collect(start:step:stop)
end
export createTimestamps

"""

Synthesize an OhlcvBar using values hashed on timestamp

"""
function synthesizeOhlcvBar(timestamp::DateTime)::OhlcvBar

    # this is done to allow high and low to be assigned the largest
    # and smallest of the four generated values, as we expect them to
    # be
    ohlc = sort([
        Float64(hash("0 $timestamp"))%1000000/100.0,
        Float64(hash("1 $timestamp"))%1000000/100.0,
        Float64(hash("2 $timestamp"))%1000000/100.0,
        Float64(hash("3 $timestamp"))%1000000/100.0,
    ])

    volume = Int64(hash("volume $timestamp")/2)

    return JSON3.read("""{
    "timestamp":"$(timestamp)",
    "open":$(ohlc[2]),
    "high":$(ohlc[4]),
    "low":$(ohlc[1]),
    "close":$(ohlc[3]),
    "volume":$(volume)
}""",OhlcvBar)
end
export synthesizeOhlcvBar

"""

Leverage synthesizeOhlcvBar to synthesize a Vector(OhlcvBar) given a range of timestamps

"""
function synthesizeOhlcvBars(timestamps::Vector{DateTime})::Vector{OhlcvBar}
    return map(synthesizeOhlcvBar,timestamps)
end
export synthesizeOhlcvBars

"""

Serialize Vector{OhlcvBar} to a file

"""
function serializeOhlcvBars(filePath::String,bars::Vector{OhlcvBar})
    open(filePath,"w") do io
        JSON3.pretty(io,bars)
    end

end
export serializeOhlcvBars

"""

Deserialize file to Vector{OhlcvBar}

"""
function deserializeOhlcvBars(filePath::String)::Vector{OhlcvBar}
    json_string = read(filePath,String)
    return JSON3.read(json_string,Vector{OhlcvBar})
end
export deserializeOhlcvBars

"""

Pretty print Vector{OhlcvBar} to String

"""
function prettyStringOhlcvBars(bars::Vector{OhlcvBar})::String
    io = IOBuffer()
    JSON3.pretty(io,bars)
    return replace(String(take!(io)), "\"" => "'")
end
export prettyStringOhlcvBars

"""

Merge two Vector{OhlcvBar}s into one sorted Vector{OhlcvBar} without duplicates

"""
function mergeBars(a::Vector{OhlcvBar},b::Vector{OhlcvBar})::Vector{OhlcvBar}
    return sort(collect(Set([a...,b...])))
end
export mergeBars

"""

Comparison predicate for sorting OhlcvBar s

"""
function Base.isless(a::OhlcvBar,b::OhlcvBar)::Bool
    return isless(a.timestamp,b.timestamp)
end

"""

Equality predicate for OhlcvBar s

"""
function Base.isequal(a::OhlcvBar,b::OhlcvBar)::Bool
    return ((a.timestamp == b.timestamp)
            && (a.open == b.open)
            && (a.high == b.high)
            && (a.low == b.low)
            && (a.close == b.close)
            && (a.volume == b.volume))
end

"""

hash function for OhlcvBar s

"""
function Base.hash(x::OhlcvBar)::UInt
    return hash(x.timestamp,hash(x.open,hash(x.high,hash(x.low,hash(x.close,hash(x.volume))))))
end

"""

Use deserializeOhlcvBars, serializeOhlcvBars, and mergeBars to create
the ability to read a collection of gzipped JSON files and merge their
contents into a single Vector{OhlcvBar} file

"""
function accumulateOhlcvBars(accumulationFile::String,converter::Function,filesToAccumulate::Vector{String})

    # read the contents of the accumulation file from disk
    accumulatedBars = deserializeOhlcvBars(accumulationFile)

    # read each of the filesToAccumulate (a collection of gzipped JSON
    # files) in turn, accumulating their contents into the contents of
    # the accumulation file
    for fileToAccumulate ∈ filesToAccumulate
        fileBars = converter(readGZippedJson(fileToAccumulate))
        accumulatedBars = mergeBars(accumulatedBars,fileBars)
    end

    # write the contents of the accumulation file back to disk
    serializeOhlcvBars(accumulationFile,accumulatedBars)

end
export accumulateOhlcvBars
