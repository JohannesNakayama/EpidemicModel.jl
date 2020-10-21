mutable struct Citizen <: Agents.AbstractAgent
    id::Int64
    pos::Int64
    home::Int64
    neuroticism::Float64
    trust_authorities::Float64
    fear::Float64
    socialnorm::Float64
    socialnorm_memory::Array{Any, 1}
    behavior::Bool
    behavior_buffer::Bool
    quarantined::Bool
    state::Symbol
    ticks_exposed::Int64
    ticks_infected::Int64
    ticks_quarantined::Int64
    incubation_period::Int64
    infection_duration::Int64
end

Citizen(;
    id::Int64, pos::Int64, home::Int64,
    neuroticism::Float64, trust_authorities::Float64, fear::Float64,
    socialnorm::Float64, socialnorm_memory::Array{Float64, 1},
    behavior::Bool, behavior_buffer::Bool,
    quarantined::Bool, state::Symbol,
    ticks_exposed::Int64, ticks_infected::Int64, ticks_quarantined::Int64,
    incubation_period::Int64, infection_duration::Int64
) = Citizen(
    id, pos, home,
    neuroticism, trust_authorities, fear,
    socialnorm, socialnorm_memory,
    behavior, behavior_buffer,
    quarantined, state,
    ticks_exposed, ticks_infected, ticks_quarantined,
    incubation_period, infection_duration
)

Citizen(id, pos, state) = Citizen(
    id=id, pos=pos, home=pos,
    neuroticism=randn_unit(), trust_authorities=randn_unit(), fear=0.0,
    socialnorm=0.0, socialnorm_memory=Float64[],
    behavior=false, behavior_buffer=false,
    quarantined=false, state=state,
    ticks_exposed=0, ticks_infected=0, ticks_quarantined=0,
    incubation_period=rand_incubation(), infection_duration=rand_duration()
)

function randn_unit()
    normal_distribution = Distributions.Normal(0.5, 0.2)
    random_normal_number = Distributions.rand(normal_distribution)
    if (random_normal_number < 0) | (random_normal_number > 1)
        random_normal_number = randn_unit()
    end
    return random_normal_number
end

function rand_incubation(α=2.14532, θ=1.5626)
    gamma_distribution = Distributions.Gamma(α, θ)
    random_gamma_number = Distributions.rand(gamma_distribution)
    random_incubation = trunc(Int64, round(random_gamma_number * 10))
    return random_incubation
end

function rand_duration(λ=17.5)
    poisson_distribution = Distributions.Poisson(λ)
    random_poisson_number = Distributions.rand(poisson_distribution)
    random_duration = trunc(Int64, round(random_poisson_number * 10))
    return random_duration
end
