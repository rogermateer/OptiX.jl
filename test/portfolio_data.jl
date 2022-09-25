# Tests for Portfolio Data related stuff, such as managing transaction
# and holding data

using Test
using TestSetExtensions
using SafeTestsets

@testset ExtendedTestSet "Portfolio Data" begin

    @safetestset "Find all relevant transaction files" begin
        using OptiX
        relevantFiles = findFiles("../data","EasyEquities","EURtransactions")
        @test length(relevantFiles) == 3
        @test exampleFile.transactionV1 == relevantFiles[1]
        @test exampleFile.transactionV2 == relevantFiles[2]
        @test exampleFile.transactionV3 == relevantFiles[3]
    end

    @safetestset "Convert v1 EasyEquities transaction file into Vector{TransactionBar}" begin
        using OptiX
        json = readGZippedJson(exampleFile.transactionV1)    
    end

end
