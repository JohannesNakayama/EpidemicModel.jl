configs = Dict()
setup = [
    (transmission_prob, behavior_activated)
    for transmission_prob in 0:0.01:0.1
    for behavior_activated in [true, false]
]
for (i, (transmission_prob, behavior_activated)) in enumerate(setup)
    configs[i] = EpidemicModel.Config(
        n_nodes=300,
        n0=3,
        k=3,
        agentcount=1000,
        transmission_prob=transmission_prob,
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
