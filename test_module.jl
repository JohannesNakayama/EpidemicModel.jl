include(joinpath("src", "EpidemicModel.jl"))
begin
    configs = Dict()
    for (i, behavior_reduction_factor) in enumerate(0:0.25:1)
        configs[i] = EpidemicModel.Config(
            n_nodes=100,
            n0=3,
            k=3,
            agentcount=100,
            transmission_prob=0.05,
            test_prob=0.8,
            quarantine_duration=140,
            behavior_reduction_factor=behavior_reduction_factor,
            behavior_activated=true,
            tick_authority_recommendation=100,
            tick_authority_policy=200,
            n_public_spaces=10,
            initial_infectives=1,
            n_iter=1000
        )
    end
    EpidemicModel.run_batch(configs=configs, replicates=2, batchname="test", compress=true)
end