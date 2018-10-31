using Test
using RegisterUtilities

@testset "Counter test" begin
    for empty_gridsize in ((), (0,), (1,0), (1,-1), (1,0,1))
        for c in Counter(empty_gridsize)
            @test c == nothing
        end
    end
    for (gridsize, index_vec) in (((1,),[[1]]), ((2,3),[[1,1],[2,1],[1,2],[2,2],[1,3],[2,3]]),
            ((2,3,4), [[1, 1, 1],[2, 1, 1],[1, 2, 1],[2, 2, 1],[1, 3, 1],[2, 3, 1],
                       [1, 1, 2],[2, 1, 2],[1, 2, 2],[2, 2, 2],[1, 3, 2],[2, 3, 2],
                       [1, 1, 3],[2, 1, 3],[1, 2, 3],[2, 2, 3],[1, 3, 3],[2, 3, 3],
                       [1, 1, 4],[2, 1, 4],[1, 2, 4],[2, 2, 4],[1, 3, 4],[2, 3, 4]]))
        cnt = Array{Array{Int64,1},1}()
        for c in Counter(gridsize)
            push!(cnt,c)
        end
        @test cnt == index_vec
    end
end
