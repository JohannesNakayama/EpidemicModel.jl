function run_model!(; model::AgentBasedModel, steps::Int64)
    agent_df, model_df = Agents.run!(
        model, agent_step!, model_step!, steps,
        adata=[
            :pos, :home, :neuroticism, :trust_authorities, :fear, :socialnorm,
            :behavior, :quarantined, :state, :incubation_period, :infection_duration
        ],
        mdata=[
            :S_count, :E_count, :Iu_count, :Id_count, :I_count, :R_count, :B_count,
            :Id_cumulative, :I_cumulative, :new_cases_real, :new_cases_detected
        ]
    )
    return agent_df, model_df
end

function run_experiment(; config::Config, replicates::Int64, rnd_seed::Int64)
    Random.seed!(rnd_seed)
    agent_df_list = DataFrames.DataFrame[]
    model_df_list = DataFrames.DataFrame[]
    networks = Dict()
    for rep in 1:replicates
        space = create_space(config)
        model = initialize_model(config, space)
        networks[rep] = deepcopy(model.space.graph)
        agent_df, model_df = run_model!(model=model, steps=config.n_iter)
        agent_df[!, :replicate] .= deepcopy(rep)
        model_df[!, :replicate] .= deepcopy(rep)
        push!(agent_df_list, deepcopy(agent_df))
        push!(model_df_list, deepcopy(model_df))
    end
    agent_df = reduce(vcat, agent_df_list)
    model_df = reduce(vcat, model_df_list)
    return networks, agent_df, model_df
end

function run_batch(; configs::Dict, replicates::Int64, batchname::String, compress::Bool)
    make_folders(batchname)
    path = joinpath("experiments", batchname)
    progress_bar = ProgressMeter.Progress(length(keys(configs)) * 2, 1, "Running simulations...")
    for config_key in keys(configs)
        networks, agent_df, model_df = run_experiment(config=configs[config_key], replicates=replicates, rnd_seed=0)
        agent_attributes, agent_dynamics = decompose_adata(agent_df, config_key)
        agent_attributes_filename = "config_" * lpad(string(config_key), 2, "0") * "_agent_attributes.feather"
        agent_dynamics_filename = "config_" * lpad(string(config_key), 2, "0") * "_agent_dynamics.feather"
        mdata_filename = "config_" * lpad(string(config_key), 2, "0") * "_mdata.feather"
        ProgressMeter.next!(progress_bar)
        names_to_camelcase!(agent_attributes)
        names_to_camelcase!(agent_dynamics)
        names_to_camelcase!(model_df)
        write_dataframe(df=agent_attributes, filename=agent_attributes_filename, path=path)
        write_dataframe(df=agent_dynamics, filename=agent_dynamics_filename, path=path)
        write_dataframe(df=model_df, filename=mdata_filename, path=path)
        write_networks(networks, path=path, config_key=config_key)
        ProgressMeter.next!(progress_bar)
    end
    println("Simulations done.")
    configs_to_dataframe(configs, path=path, write=true)
    compute_summary_statistics(configs=configs, path=path, write=true)
    compute_summary_agent_states(configs=configs, path=path, write=true)
    println("Summaries done.")
    # write_configs(configs=configs, path=path)
    if compress
        patterns = ["_graph.txt", "_mdata.feather", "_agent_attributes.feather", "_agent_dynamics.feather"]
        archive_filenames = ["graphs.7z", "mdata.7z", "agent_attributes.7z", "agent_dynamics.7z"]
        for (pattern, archive_filename) in zip(patterns, archive_filenames)
            compress_data(path=path, pattern=pattern, archive_filename=archive_filename);
        end
    end
    println("Batch $batchname run successfully.")
    return "successful"
end
