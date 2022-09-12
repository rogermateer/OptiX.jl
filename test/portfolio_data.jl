# Tests for Portfolio Data related stuff, such as managing transaction
# and holding data

using Test
using TestSetExtensions

@testset ExtendedTestSet "Portfolio Data" begin

    @safetestset "Find all relevant transaction files" begin
        include("../src/portfolio_data.jl")
        relevantFiles = findFiles("../data","EasyEquities","EURtransactions")
        @test length(relevantFiles) == 3
        @test exampleV1TransactionFile == relevantFiles[1]
        @test exampleV2TransactionFile == relevantFiles[2]
        @test exampleV3TransactionFile == relevantFiles[3]
    end

    @safetestset "Convert v1 EasyEquities transaction file into Vector{TransactionBar}" begin
        include("../src/portfolio_data.jl")
        json = readGZippedJson(exampleV1TransactionFile)    
    end

end
