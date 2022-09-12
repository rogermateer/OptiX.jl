# Tests for common Infrastructural stuff, which is used by multiple other modules

using Test
using TestSetExtensions
using SafeTestsets

@testset ExtendedTestSet "Common" begin
    @safetestset "Read a GZipped JSON file" begin
        include("../src/common.jl")
        json = readGZippedJson(exampleDailyFile)
        @test (length(json["Time Series (Daily)"])) == 5680
    end
end

#=
@testset ExtendedTestSet "Example" begin
    @safetestset "Feature 1" begin
        a = [1, 2, 3]
        b = [1, 2, 4]

        # Will display nicely thanks to `ExtendedTestSet`
        @test a == b
    end

    @safetestset "Feature 2" begin
        # Will fail thanks to `@safetestset`
        @test a == [1, 2, 3]
    end
end
=#
