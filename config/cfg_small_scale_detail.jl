configs = Dict()
setups = [
    (false, 100, 200),
    (true, 100, 1001),
    (true, 1001, 100),
    (true, 100, 200)
]
for (i, setup) in enumerate(setups)
    configs[i] = EpidemicModel.Config(
        n_nodes=300,
        n0=3,
        k=3,
        agentcount=1000,
        transmission_prob=0.05,
        test_prob=0.8,
        quarantine_duration=140,
        behavior_reduction_factor=0.25,
        behavior_activated=setup[1],
        tick_authority_recommendation=setup[2],
        tick_authority_policy=setup[3],
        n_public_spaces=100,
        initial_infectives=5,
        n_iter=1000
    )
end
