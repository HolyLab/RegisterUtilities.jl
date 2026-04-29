# RegisterUtilities.jl

[![CI](https://github.com/HolyLab/RegisterUtilities.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/HolyLab/RegisterUtilities.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/HolyLab/RegisterUtilities.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/HolyLab/RegisterUtilities.jl)
[![version](https://juliahub.com/docs/General/RegisterUtilities/stable/version.svg)](https://juliahub.com/ui/Packages/General/RegisterUtilities)

Utility types and functions for image-registration workflows in the
[HolyLab](https://github.com/HolyLab) ecosystem.

## Installation

This package depends on
[RegisterCore.jl](https://github.com/HolyLab/RegisterCore.jl), which lives in
the [HolyLab registry](https://github.com/HolyLab/HolyLabRegistry). Add that
registry once before installing:

```julia
using Pkg
pkg"registry add General https://github.com/HolyLab/HolyLabRegistry.git"
Pkg.add("RegisterUtilities")
```

## Usage

### `Counter` — column-major multi-dimensional index iterator

`Counter` yields every `Vector{Int}` index from `[1,1,…,1]` to `max` in
column-major (first-index-fastest) order. Unlike `CartesianIndices`, the
yielded values are plain vectors, which is convenient for arithmetic.

```julia
using RegisterUtilities

c = Counter((2, 3))
collect(c)
# [[1,1],[2,1],[1,2],[2,2],[1,3],[2,3]]

length(Counter((4, 5, 6)))  # 120
```

### `block_center` — center coordinate of a block

Returns the 1-based center of a block with the given dimensions, using the
same convention as `MismatchArray` blocks: center of dimension `i` is
`(sz[i] >> 1) + 1`.

```julia
block_center(5)       # (3,)
block_center(4, 6)    # (3, 4)
block_center(5, 5, 5) # (3, 3, 3)
```

### `quadratic` — quadratic-form array

Fills a 2-D array where each element `(i,j)` equals `uᵀ Q u`, with
`u = [i,j] - center` and `center = block_center(m,n) .+ shift`. The second
method wraps the result in a `MismatchArray` with a given denominator.

```julia
using RegisterUtilities, LinearAlgebra

Q = [1.0 0.0; 0.0 1.0]   # identity — distance² from center
A = quadratic(5, 5, [0, 0], Q)
# 5×5 matrix of squared distances from the block center (3, 3)

using RegisterCore
denom = ones(5, 5)
ma = quadratic(denom, [0, 0], Q)   # returns a MismatchArray
```

### `tighten` — narrow element type

Converts a heterogeneous or overly-wide array (e.g. `Array{Real}`) to the
narrowest concrete type that holds all its values.

```julia
A = Real[1, 2.0, 3f0]
B = tighten(A)
eltype(B)   # Float64
```
