using OptiX
using Test
using TestSetExtensions

exampleDailyFile = "../data/2022/05/27/AlphaVantage.TIME_SERIES_DAILY.AAPL.2022-05-27.json.gz"
exampleIntradayFile = "../data/2022/05/27/AlphaVantage.TIME_SERIES_INTRADAY.AAPL.2022-05-27.json.gz"
exampleAccumulationFile = "../data/Accumulation.json"

@testset ExtendedTestSet "Read a GZipped JSON file" begin
    json = readGZippedJson(exampleDailyFile)
    @test (length(json["Time Series (Daily)"])) == 5680
end

@testset ExtendedTestSet "Find all relevant files" begin
    relevantFiles = findFiles("../data","AlphaVantage","TIME_SERIES_DAILY","AAPL");
    @test length(relevantFiles) == 5
    @test exampleDailyFile == relevantFiles[3]
end

@testset ExtendedTestSet "Convert AlphaVantage TIME_SERIES_DAILY file into Vector{OhlcvBar}" begin
    json = readGZippedJson(exampleDailyFile)
    bars = convertAlphaVantageTimeSeriesDaily(json)
    @test length(bars) == 5680
end

@testset ExtendedTestSet "Convert AlphaVantage TIME_SERIES_INTRADAY file into Vector{OhlcvBar}" begin
    json = readGZippedJson(exampleIntradayFile)
    bars = convertAlphaVantageTimeSeriesIntraday(json)
    @test length(bars) == 8601
end

@testset ExtendedTestSet "Serialize and deserialize Vector{OhlcvBar} to a human-readable file" begin
    # synthesize a Vector{OhlcvBar} with contents hashed on supplied timestamps
    bars = synthesizeOhlcvBars(createTimestamps(DateTime("2022-05-01"),DateTime("2022-06-01"),Dates.Day(1)))

    # serialize it
    serializeOhlcvBars(exampleAccumulationFile,bars)

    # deserialize it
    BARS = deserializeOhlcvBars(exampleAccumulationFile)

    # verify that the result is the same as the original Vector{OhlcvBar}
    @test prettyStringOhlcvBars(BARS) == prettyStringOhlcvBars(bars)

end
