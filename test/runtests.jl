using Test
using Aqua
using ExplicitImports
using RegisterUtilities

@testset "Aqua" begin
    Aqua.test_all(RegisterUtilities)
end

@testset "ExplicitImports" begin
    test_explicit_imports(RegisterUtilities)
end

@testset "Counter test" begin
    for empty_gridsize in ((), (0,), (1, 0), (1, -1), (1, 0, 1))
        for c in Counter(empty_gridsize)
            @test c == nothing
        end
    end
    for (gridsize, index_vec) in (
            ((1,), [[1]]), ((2, 3), [[1, 1], [2, 1], [1, 2], [2, 2], [1, 3], [2, 3]]),
            (
                (2, 3, 4), [
                    [1, 1, 1], [2, 1, 1], [1, 2, 1], [2, 2, 1], [1, 3, 1], [2, 3, 1],
                    [1, 1, 2], [2, 1, 2], [1, 2, 2], [2, 2, 2], [1, 3, 2], [2, 3, 2],
                    [1, 1, 3], [2, 1, 3], [1, 2, 3], [2, 2, 3], [1, 3, 3], [2, 3, 3],
                    [1, 1, 4], [2, 1, 4], [1, 2, 4], [2, 2, 4], [1, 3, 4], [2, 3, 4],
                ],
            ),
        )
        cnt = Array{Array{Int64, 1}, 1}()
        for c in Counter(gridsize)
            push!(cnt, c)
        end
        @test cnt == index_vec
    end
    # AbstractVector constructor
    cnt32 = [c for c in Counter(Int32[2, 3])]
    @test cnt32 == [[1,1],[2,1],[1,2],[2,2],[1,3],[2,3]]
end

@testset "block_center" begin
    @test block_center(1) == (1,)
    @test block_center(2) == (2,)
    @test block_center(4) == (3,)
    @test block_center(5) == (3,)
    @test block_center(4, 6) == (3, 4)
    @test block_center(8) == (5,)
end
