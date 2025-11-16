mutable struct SegTree{T, F}
    len::Int
    data::Vector{T}
    binary_op::F

    function SegTree(len::Int, init::T, binary_op::F) where {T, F}
        seg_len = 1
        while seg_len < len
            seg_len = seg_len << 1
        end
        data = fill(init, 2 * seg_len - 1)
        new{T, F}(len, data, binary_op)
    end
end

function SegTree(data::Vector{T}, init::T, binary_op::F) where {T, F}
    len = length(data)
    st = SegTree(len, init, binary_op)

    leaf_count = length(st.data) >> 1

    for i in 1:len
        st.data[i + leaf_count] = data[i]
    end
    bottom_up!(st)

    return st
end


function update!(st::SegTree, idx::Int, value::T; f::F = (x, new)->new) where {T, F}
    n = length(st.data) >> 1
    i = idx + n

    st.data[i] = f(st.data[i], value)
    while i > 1
        i = div(i, 2)
        st.data[i] = st.binary_op(st.data[2 * i], st.data[2 * i + 1])
    end
end

function bottom_up!(st::SegTree)
    leaf_count = length(st.data) >> 1
    for j in leaf_count:-1:1
        st.data[j] = st.binary_op(st.data[2 * j], st.data[2 * j + 1])
    end
end

function find(st::SegTree, l::Int, r::Int, id::T) where {T}
    n = (length(st.data)) >> 1
    i = n + l
    j = n + r
    resl = id
    resr = id

    while i <= j
        if i & 1 == 1
            resl = st.binary_op(st.data[i], resl)
            i += 1
        end
        if j & 1 == 0
            resr = st.binary_op(resr, st.data[j])
            j -= 1
        end

        i >>= 1
        j >>= 1
    end
    return st.binary_op(resl, resr)
end

# for debug
Base.getindex(st::SegTree, idx::Int) = st.data[idx + (length(st.data) + 1) >> 1 - 1]
Base.show(io::IO, st::SegTree) = print(io, "SegTree (length=$(st.len)): ", st.data[range(length(st.data) >> 1 + 1, length=st.len)])