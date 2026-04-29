using Test
using Aqua
using ExplicitImports
using LinearAlgebra: I
using RegisterCore: RegisterCore
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

@testset "quadratic" begin
    Q = Matrix(1.0I, 2, 2)
    m, n = 5, 7
    A = quadratic(m, n, (0, 0), Q)
    @test size(A) == (m, n)
    c = block_center(m, n)
    @test A[c...] == 0.0
    @test all(>=(0), A)
    @inferred quadratic(m, n, (0, 0), Q)

    # shifting the center moves the zero
    A2 = quadratic(m, n, (1, 0), Q)
    @test A2[c[1] + 1, c[2]] == 0.0

    # matrix-denom variant returns a MismatchArray of the right size
    denom = ones(m, n)
    result = quadratic(denom, (0, 0), Q)
    @test result isa RegisterCore.MismatchArray
    @test size(result) == (m, n)
end

@testset "tighten" begin
    # heterogeneous Any-array gets promoted
    A = Any[1, 2.0, 3f0]
    result = tighten(A)
    @test eltype(result) == Float64
    @test result ≈ [1.0, 2.0, 3.0]

    # already-concrete array is unchanged in value and type
    B = [1, 2, 3]
    @test tighten(B) == B
    @test eltype(tighten(B)) == Int
end
