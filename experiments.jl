include(joinpath("src", "EpidemicModel.jl"))
CONFIG_FOLDER = "config"

@time begin
    config_file = "cfg_main_agent_density.jl"
    include(joinpath(CONFIG_FOLDER, config_file))  # config dictionary created in config script
    EpidemicModel.run_batch(
        configs=configs, replicates=10, batchname="main_agent_density", compress=true
    )
end

@time begin
    config_file = "cfg_main_behavior_reduction_factor.jl"
    include(joinpath(CONFIG_FOLDER, config_file))  # config dictionary created in config script
    EpidemicModel.run_batch(
        configs=configs, replicates=10, batchname="main_behavior_reduction_factor", compress=true
    )
end

@time begin
    config_file = "cfg_main_policy_reach.jl"
    include(joinpath(CONFIG_FOLDER, config_file))  # config dictionary created in config script
    EpidemicModel.run_batch(
        configs=configs, replicates=10, batchname="main_policy_reach", compress=true
    )
end

@time begin
    config_file = "cfg_main_test_probability.jl"
    include(joinpath(CONFIG_FOLDER, config_file))  # config dictionary created in config script
    EpidemicModel.run_batch(
        configs=configs, replicates=10, batchname="main_test_probability", compress=true
    )
end

@time begin
    config_file = "cfg_main_tick_authority_policy.jl"
    include(joinpath(CONFIG_FOLDER, config_file))  # config dictionary created in config script
    EpidemicModel.run_batch(
        configs=configs, replicates=10, batchname="main_tick_authority_policy", compress=true
    )
end

@time begin
    config_file = "cfg_main_tick_authority_recommendation.jl"
    include(joinpath(CONFIG_FOLDER, config_file))  # config dictionary created in config script
    EpidemicModel.run_batch(
        configs=configs, replicates=10, batchname="main_tick_authority_recommendation", compress=true
    )
end

@time begin
    config_file = "cfg_main_transmission_probability.jl"
    include(joinpath(CONFIG_FOLDER, config_file))  # config dictionary created in config script
    EpidemicModel.run_batch(
        configs=configs, replicates=10, batchname="main_transmission_probability", compress=true
    )
end

@time begin
    config_file = "cfg_small_scale_detail.jl"
    include(joinpath(CONFIG_FOLDER, config_file))  # config dictionary created in config script
    EpidemicModel.run_batch(
        configs=configs, replicates=1, batchname="small_scale_detail", compress=true
    )
end
