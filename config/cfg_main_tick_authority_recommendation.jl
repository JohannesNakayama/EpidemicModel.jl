configs = Dict()
for (i, tick_authority_recommendation) in enumerate(0:20:300)
    configs[i] = EpidemicModel.Config(
        n_nodes=300,
        n0=3,
        k=3,
        agentcount=1000,
        transmission_prob=0.05,
        test_prob=0.8,
        quarantine_duration=140,
        behavior_reduction_factor=0.25,
        behavior_activated=true,
        tick_authority_recommendation=tick_authority_recommendation,
        tick_authority_policy=1001,
        n_public_spaces=100,
        initial_infectives=5,
        n_iter=1000
    )
end
