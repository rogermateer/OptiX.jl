using OptiX
using Test
using TestSetExtensions

@testset ExtendedTestSet "All the tests" begin
    show(ARGS)
    @includetests ARGS
end
