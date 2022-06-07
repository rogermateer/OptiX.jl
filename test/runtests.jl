using OptiX
using Test
using TestSetExtensions

#=
@testset ExtendedTestSet "JSON3 StructTypes type generation" begin
    JSON3.writetypes("../data/2022/05/27/AlphaVantage.TIME_SERIES_DAILY.AAPL.2022-05-27.json",
                     "../AlphaVantageTimeSeriesDailyTypes.jl";
                     module_name=:AlphaVantageTimeSeriesDailyTypes,
                     root_name=:AlphaVantageTimeSeriesDaily)

    # FIXME: unfortunately, AlphaVantage JSON uses timestamps as keys,
    # which, AFAIK, JSON3 type generation doesn't handle (too
    # easily/at all)
end
=#

exampleFile = "../data/2022/05/27/AlphaVantage.TIME_SERIES_DAILY.AAPL.2022-05-27.json.gz"

@testset ExtendedTestSet "Read a GZipped JSON file" begin
    json = readGZippedJson(exampleFile)
    @test (length(json["Time Series (Daily)"])) == 5680
end

@testset ExtendedTestSet "Find all relevant files" begin
    relevantFiles = findFiles("../data","AlphaVantage","TIME_SERIES_DAILY","AAPL");
    @test length(relevantFiles) == 5
    @test exampleFile == relevantFiles[3]
end

@testset ExtendedTestSet "Convert AlphaVantage TIME_SERIES_DAILY file into Vector{OhlcvBar}" begin
    json = readGZippedJson(exampleFile)
    bars = convertAlphaVantageTimeSeriesDaily(json)
    @test length(bars) == 5680
end
