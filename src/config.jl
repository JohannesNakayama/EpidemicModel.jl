struct Config
    n_nodes::Int64
    n0::Int64
    k::Int64
    agentcount::Int64
    transmission_prob::Float64
    test_prob::Float64
    quarantine_duration::Int64
    behavior_reduction_factor::Float64
    behavior_activated::Bool
    tick_authority_recommendation::Int64
    tick_authority_policy::Int64
    n_public_spaces::Int64
    initial_infectives::Int64
    n_iter::Int64
end

Config(;
    n_nodes::Int64, n0::Int64, k::Int64, agentcount::Int64,
    transmission_prob::Float64, test_prob::Float64, quarantine_duration::Int64,
    behavior_reduction_factor::Float64, behavior_activated::Bool,
    tick_authority_recommendation::Int64, tick_authority_policy::Int64,
    n_public_spaces::Int64, initial_infectives::Int64, n_iter::Int64
) = Config(
    n_nodes, n0, k, agentcount,
    transmission_prob, test_prob, quarantine_duration,
    behavior_reduction_factor, behavior_activated,
    tick_authority_recommendation, tick_authority_policy,
    n_public_spaces, initial_infectives, n_iter
)

Config() = Config(
    n_nodes=1_000, n0=3, k=3, agentcount=100,
    transmission_prob=0.1, test_prob=0.6, quarantine_duration=140,
    behavior_reduction_factor=0.6, behavior_activated=true,
    tick_authority_recommendation=10, tick_authority_policy=50,
    n_public_spaces=30, initial_infectives=1, n_iter=1_000
)
