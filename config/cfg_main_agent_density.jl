configs = Dict()
setup = [
    (agentcount, behavior_activated)
    for agentcount in 500:50:1000
    for behavior_activated in [true, false]
]
for (i, (agentcount, behavior_activated)) in enumerate(setup)
    configs[i] = EpidemicModel.Config(
        n_nodes=300,
        n0=3,
        k=3,
        agentcount=agentcount,
        transmission_prob=0.05,
        test_prob=0.8,
        quarantine_duration=140,
        behavior_reduction_factor=0.25,
        behavior_activated=behavior_activated,
        tick_authority_recommendation=100,
        tick_authority_policy=200,
        n_public_spaces=100,
        initial_infectives=5,
        n_iter=1000
    )
end
