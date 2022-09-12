# Tests for Market Data related stuff, such as managing time series
# for companies equities, industry sector and market indices, exchange
# rates, etc

using Test
using TestSetExtensions
using SafeTestsets

@testset ExtendedTestSet "Market Data" begin

    @safetestset "Find all relevant time series files" begin
        include("../src/market_data.jl")
        relevantFiles = findFiles("../data","AlphaVantage","TIME_SERIES_DAILY","AAPL")
        @test length(relevantFiles) == 5
        @test exampleDailyFile == relevantFiles[3]
    end

    @safetestset "Convert AlphaVantage TIME_SERIES_DAILY file into Vector{OhlcvBar}" begin
        include("../src/market_data.jl")
        json = readGZippedJson(exampleDailyFile)
        bars = convertAlphaVantageTimeSeriesDaily(json)
        @test length(bars) == 5680
    end

    @safetestset "Convert AlphaVantage TIME_SERIES_INTRADAY file into Vector{OhlcvBar}" begin
        include("../src/market_data.jl")
        json = readGZippedJson(exampleIntradayFile)
        bars = convertAlphaVantageTimeSeriesIntraday(json)
        @test length(bars) == 8601
    end

    @safetestset "Serialize and deserialize Vector{OhlcvBar} to a human-readable file" begin
        include("../src/market_data.jl")
        # synthesize a Vector{OhlcvBar} with contents hashed on supplied timestamps
        bars = synthesizeOhlcvBars(createTimestamps(DateTime("2022-05-01"),DateTime("2022-06-01"),Dates.Day(1)))
        # serialize it
        serializeOhlcvBars(exampleAccumulationFile,bars)
        # deserialize it
        BARS = deserializeOhlcvBars(exampleAccumulationFile)
        # verify that the result is the same as the original Vector{OhlcvBar}
        @test prettyStringOhlcvBars(BARS) == prettyStringOhlcvBars(bars)
    end

    @safetestset "Merge two sorted Vector{OhlcvBar}s into one sorted Vector{OhlcvBar}" begin
        include("../src/market_data.jl")
        barsOdd = synthesizeOhlcvBars(createTimestamps(DateTime("2022-05-01"),DateTime("2022-06-01"),Dates.Day(2)))
        barsEven = synthesizeOhlcvBars(createTimestamps(DateTime("2022-05-02"),DateTime("2022-06-01"),Dates.Day(2)))
        bars = synthesizeOhlcvBars(createTimestamps(DateTime("2022-05-01"),DateTime("2022-06-01"),Dates.Day(1)))
        @test prettyStringOhlcvBars(mergeBars(barsOdd,barsEven)) == prettyStringOhlcvBars(bars)
        @test prettyStringOhlcvBars(mergeBars(barsEven,barsOdd)) == prettyStringOhlcvBars(bars)
        @test prettyStringOhlcvBars(mergeBars([barsEven...,barsOdd...],barsOdd)) == prettyStringOhlcvBars(bars)
    end

    @safetestset "Accumulate Vector{OhlcvBars} from a collection of gzipped JSON files into a single human-readable file" begin
        include("../src/market_data.jl")

        # start with an empty accumulation file for the purposes of this test
        accumulationFile = "../data/Accumulation.AAPL.json"
        serializeOhlcvBars(accumulationFile,OhlcvBar[])
        @test length(deserializeOhlcvBars(accumulationFile)) == 0

        filesToAccumulate = findFiles("../data","AlphaVantage","TIME_SERIES_DAILY","AAPL")
        converter = convertAlphaVantageTimeSeriesDaily
        accumulateOhlcvBars(accumulationFile,converter,filesToAccumulate)
        @test length(deserializeOhlcvBars(accumulationFile)) == 5682

        filesToAccumulate = findFiles("../data","AlphaVantage","TIME_SERIES_INTRADAY","AAPL")
        converter = convertAlphaVantageTimeSeriesIntraday
        accumulateOhlcvBars(accumulationFile,converter,filesToAccumulate)
        @test length(deserializeOhlcvBars(accumulationFile)) == 16071
    end
  
end
