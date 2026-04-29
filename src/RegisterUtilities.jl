"""
    RegisterUtilities

Utility types and functions for image-registration workflows.

Exports:
- [`Counter`](@ref): column-major multi-dimensional index iterator.
- [`quadratic`](@ref): construct a quadratic-form array or `MismatchArray`.
- [`block_center`](@ref): compute the center coordinate of a block.
- [`tighten`](@ref): narrow an array to its tightest concrete element type.
"""
module RegisterUtilities

export Counter

"""
    Counter(max::AbstractVector{<:Integer})
    Counter(sz::Tuple)

An iterator that yields every `Vector{Int}` index tuple from `[1, 1, …, 1]`
to `max` (or `collect(sz)`), traversing in column-major (first-index-fastest)
order.

Unlike `CartesianIndices`, `Counter` yields plain `Vector{Int}` values, making
it convenient when the index needs to be used in arithmetic expressions.

`length(c)` returns the total number of elements (`prod(max)`), or `0` if any
dimension is ≤ 0.

# Examples
```julia
c = Counter((2, 3))
collect(c)  # [[1,1],[2,1],[1,2],[2,2],[1,3],[2,3]]
```
"""
struct Counter
    max::Vector{Int}
end
Counter(sz::Tuple) = Counter(Int[sz...])
Counter(max::AbstractVector{<:Integer}) = Counter(convert(Vector{Int}, max))

Base.length(c::Counter) = isempty(c.max) || any(<=(0), c.max) ? 0 : prod(c.max)

function Base.iterate(c::Counter)
    N = length(c.max)
    (N == 0 || any(c.max .<= 0)) && return nothing
    state = ones(Int, N)
    return copy(state), state
end
function Base.iterate(c::Counter, state::Vector{Int})
    state[1] += 1
    i = 1
    while state[i] > c.max[i] && i < length(state)
        state[i] = 1
        i += 1
        state[i] += 1
    end
    state[end] > c.max[end] && return nothing
    return copy(state), state
end

# Below functions are from RegisterTestUtilities

using LinearAlgebra: LinearAlgebra, dot
using RegisterCore: RegisterCore, MismatchArray

export quadratic, block_center, tighten

"""
    quadratic(m, n, shift, Q)
    quadratic(denom::AbstractMatrix, shift, Q)

Construct a 2-D array of quadratic-form values centered at a shifted block
center.

For each pixel `(i, j)` the value is `uᵀ Q u`, where `u = [i, j] - center`
and `center = block_center(m, n) .+ shift`.

The second method wraps the result in a `MismatchArray` using `denom` as the
denominator array; `m` and `n` are taken from `size(denom)`.

# Arguments
- `m`, `n`: output array dimensions (rows, columns).
- `denom`: an existing `AbstractMatrix` whose size sets the output dimensions
  and whose values become the denominator of the returned `MismatchArray`.
- `shift`: 2-element offset added to the block center.
- `Q`: 2×2 matrix defining the quadratic form.
"""
function quadratic(m, n, shift, Q)
    T = float(eltype(Q))
    A = zeros(T, m, n)
    c = block_center(m, n)
    cntr = [shift[1] + c[1], shift[2] + c[2]]
    u = zeros(T, 2)
    for j in 1:n, i in 1:m
        u[1], u[2] = i - cntr[1], j - cntr[2]
        A[i, j] = dot(u, Q * u)
    end
    return A
end

quadratic(denom::AbstractMatrix, shift, Q) = MismatchArray(quadratic(size(denom)..., shift, Q), denom)

"""
    block_center(sz...)

Return the 1-based center coordinate of a block with dimensions `sz` as an
`NTuple`.

The center of dimension `i` is computed as `(sz[i] >> 1) + 1`, matching the
convention used by `MismatchArray` blocks.

# Examples
```julia
block_center(5)       # (3,)
block_center(4, 6)    # (3, 4)
block_center(5, 5, 5) # (3, 3, 3)
```
"""
function block_center(sz...)
    return ntuple(i -> (sz[i] >> 1) + 1, length(sz))
end

"""
    tighten(A::AbstractArray)

Return a copy of `A` with the narrowest element type that can hold all of its
values.

Iterates over every element of `A` and accumulates a common type via
`promote_type`, then copies `A` into a new array of that type.  Useful for
converting heterogeneous or overly-wide arrays (e.g. `Array{Real}`) into a
concrete, efficient representation.

# Example
```julia
A = Real[1, 2.0, 3f0]   # element type Real
B = tighten(A)           # element type Float64
```
"""
function tighten(A::AbstractArray)
    T = typeof(first(A))
    for a in A
        T = promote_type(T, typeof(a))
    end
    At = similar(A, T)
    return copyto!(At, A)
end

end
