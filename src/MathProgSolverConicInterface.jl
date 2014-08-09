funcs = [:loadconicproblem!, :loadineqconicproblem!, :getconicdual]

for func in funcs
    @eval $(func)() = throw(MethodError($(func),()))
    eval(Expr(:export, func))
end

function loadconicproblem!(m::AbstractMathProgModel, c, A, b, cones)
    num_vars = length(c)
    nonneg_indices = Range[]
    for (cone,idx) in cones
        if cone == :free
            continue
        elseif cone == :NonNeg
            push!(nonneg_indices, idx)
        else
            error("Solver $m does not support cone $cone")
            # TODO: allow :Zero cone
        end
    end
    num_ineq_constraints = length(nonneg_indices)
    rowlb = b
    collb = b
    obj = c
    collb = fill(-Inf, num_vars)
    collb[nonneg_indices] = 0
    colub = fill(Inf, num_vars)
    loadproblem!(m, A, collb, colub, obj, rowlb, rowub, :Min)
end

function loadineqconicproblem!(m::AbstractMathProgModel, c, A, b, G, h, cones)
    num_vars = length(c)
    nonneg_indices = Range[]
    for (cone,idx) in cones
        if cone == :free
            continue
        elseif cone == :NonNeg
            push!(nonneg_indices, idx)
        else
            error("Solver $m does not support cone $cone")
            # TODO: allow :Zero cone
        end
    end
    num_ineq_constraints = length(nonneg_indices)
    lp_A = vcat(A, G[nonneg_indices,:])
    rowlb = vcat(b, zeros(num_ineq_constraints,1))
    collb = vcat(b, h[nonneg_indices])
    obj = c
    collb = fill(-Inf, num_vars)
    colub = fill(Inf, num_vars)
    loadproblem!(m, lp_A, collb, colub, obj, rowlb, rowub, :Min)
end