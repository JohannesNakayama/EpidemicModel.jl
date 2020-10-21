function configs_to_dataframe(configs::Dict; path::String, write::Bool=false)
    config_df = init_configs_dataframe()
    progress_bar = ProgressMeter.Progress(length(keys(configs)), 0.2, "Converting configurations...")
    for config_key in keys(configs)
        config_row = extract_config(configs, config_key)
        push!(config_df, config_row)
        ProgressMeter.next!(progress_bar)
    end
    if write
        write_dataframe(df=config_df, filename="configs.feather", path=path)
    end
    return config_df
end

function init_configs_dataframe()
    return DataFrames.DataFrame(
        Config=String[],
        Nodes=Int64[],
        N0=Int64[],
        K=Int64[],
        AgentCount=Int64[],
        TransmissionProb=Float64[],
        TestProb=Float64[],
        QuarantineDuration=Int64[],
        BehaviorReductionFactor=Float64[],
        BehaviorActivated=Bool[],
        TickAuthorityRecommendation=Int64[],
        TickAuthorityPolicy=Int64[],
        PublicSpaces=Int64[],
        InitialInfectives=Int64[],
        Iterations=Int64[]
    )
end

function extract_config(configs::Dict, config_key::Any)
    return (
        Config="config_" * lpad(config_key, 2, "0"),
        Nodes=configs[config_key].n_nodes,
        N0=configs[config_key].n0,
        K=configs[config_key].k,
        AgentCount=configs[config_key].agentcount,
        TransmissionProb=configs[config_key].transmission_prob,
        TestProb=configs[config_key].test_prob,
        QuarantineDuration=configs[config_key].quarantine_duration,
        BehaviorReductionFactor=configs[config_key].behavior_reduction_factor,
        BehaviorActivated=configs[config_key].behavior_activated,
        TickAuthorityRecommendation=configs[config_key].tick_authority_recommendation,
        TickAuthorityPolicy=configs[config_key].tick_authority_policy,
        PublicSpaces=configs[config_key].n_public_spaces,
        InitialInfectives=configs[config_key].initial_infectives,
        Iterations=configs[config_key].n_iter
    )
end

function compute_summary_statistics(; configs::Dict, path::String, write::Bool=false)
    summary_statistics = init_summary_statistics()
    progress_bar = ProgressMeter.Progress(length(keys(configs)), 0.2, "Computing summary statistics...")
    for config_key in keys(configs)
        mdata = Feather.read(joinpath(path, "config_" * lpad(config_key, 2, "0") * "_mdata.feather"))
        summary_config = summary_statistic_single_config(mdata=mdata, configs=configs, config_key=config_key)
        summary_statistics = vcat(summary_statistics, summary_config)
        ProgressMeter.next!(progress_bar)
    end
    if write
        write_dataframe(df=summary_statistics, filename="summary_statistics.feather", path=path)
    end
    return summary_statistics
end

function init_summary_statistics()
    return DataFrames.DataFrame(
        Config=String[],
        Replicate=Int64[],
        BehaviorActivated=Bool[],
        AgentCount=Int64[],
        Nodes=Int64[],
        PublicSpaces=Int64[],
        BehaviorReductionFactor=Float64[],
        TickAuthorityRecommendation=Float64[],
        TickAuthorityPolicy=Float64[],
        TransmissionProb=Float64[],
        TestProb=Float64[],
        QuarantineDuration=Int64[],
        PeakInfectiveCount=Int64[],
        TickOfPeakInfectiveCount=Int64[],
        DurationOfEpidemic=Int64[],
        FractionStillSusceptible=Float64[]
    )
end

function summary_statistic_single_config(; mdata::DataFrames.DataFrame, configs::Dict, config_key::Any)
    peak_infective_count = extract_peak_infective_count(mdata)
    tick_peak_infective_count = extract_tick_peak_infective_count(mdata)
    duration_of_epidemic = extract_duration_of_epidemic(mdata)
    fraction_still_susceptible = extract_fraction_still_susceptible(mdata, configs, config_key)
    summarized_config = @pipe peak_infective_count |>
        innerjoin(_, tick_peak_infective_count, on=:Replicate) |>
        innerjoin(_, duration_of_epidemic, on=:Replicate) |>
        innerjoin(_, fraction_still_susceptible, on=:Replicate)
    summarized_config[!, :Config] .= "config_" * lpad(config_key, 2, "0")
    summarized_config[!, :BehaviorActivated] .= configs[config_key].behavior_activated
    summarized_config[!, :AgentCount] .= configs[config_key].agentcount
    summarized_config[!, :Nodes] .= configs[config_key].n_nodes
    summarized_config[!, :PublicSpaces] .= configs[config_key].n_public_spaces
    summarized_config[!, :BehaviorReductionFactor] .= configs[config_key].behavior_reduction_factor
    summarized_config[!, :TickAuthorityRecommendation] .= configs[config_key].tick_authority_recommendation
    summarized_config[!, :TickAuthorityPolicy] .= configs[config_key].tick_authority_policy
    summarized_config[!, :TransmissionProb] .= configs[config_key].transmission_prob
    summarized_config[!, :TestProb] .= configs[config_key].test_prob
    summarized_config[!, :QuarantineDuration] .= configs[config_key].quarantine_duration
    return summarized_config
end

function extract_peak_infective_count(mdata::DataFrames.DataFrame)
    replicates = unique(mdata.Replicate)
    peak_infective_count = DataFrames.DataFrame(Replicate=Int64[], PeakInfectiveCount=Int64[])
    @sync @distributed for rep in replicates
        subset_df = mdata |>
            @filter(_.Replicate == rep) |>
            DataFrames.DataFrame
        push!(peak_infective_count, (rep, maximum(subset_df.ICount)))
    end
    return peak_infective_count
end

function extract_tick_peak_infective_count(mdata::DataFrames.DataFrame)
    replicates = unique(mdata.Replicate)
    tick_peak_infective_count = DataFrames.DataFrame(Replicate=Int64[], TickOfPeakInfectiveCount=Int64[])
    @sync @distributed for rep in replicates
        subset_df = mdata |>
            @filter(_.Replicate == rep) |>
            DataFrames.DataFrame
        peak_infective_count = maximum(subset_df.ICount)
        all_ticks_peak_infective_count = subset_df |>
            @filter(_.ICount == peak_infective_count) |>
            DataFrames.DataFrame
        push!(tick_peak_infective_count, (rep, first(all_ticks_peak_infective_count.Step)))
    end
    return tick_peak_infective_count
end

function extract_duration_of_epidemic(mdata::DataFrames.DataFrame)
    replicates = unique(mdata.Replicate)
    duration_of_epidemic = DataFrames.DataFrame(Replicate=Int64[], DurationOfEpidemic=Int64[])
    @sync @distributed  for rep in replicates
        subset_df = mdata |>
            @filter(_.Replicate == rep) |>
            DataFrames.DataFrame
        n_iter = size(subset_df)[1]
        push!(duration_of_epidemic, (rep, n_iter - (findfirst(x -> x != 0, reverse(subset_df.ICount)) + 1)))
            # find first non-zero occurence of I_count in the reversed infective time-series
            # + 1 because 0th tick (i.e., setup) is also in the dataframe
    end
    return duration_of_epidemic
end

function extract_fraction_still_susceptible(mdata::DataFrames.DataFrame, configs::Dict, config_nr::Any)
    replicates = unique(mdata.Replicate)
    agentcount = configs[config_nr].agentcount
    fraction_still_susceptible = DataFrames.DataFrame(Replicate=Int64[], FractionStillSusceptible=Float64[])
    @sync @distributed for rep in replicates
        subset_df = mdata |>
            @filter(_.Replicate == rep) |>
            DataFrames.DataFrame
        last_step = maximum(subset_df.Step)
        last_step_df = subset_df |>
            @filter(_.Step == last_step) |>
            DataFrames.DataFrame
        push!(fraction_still_susceptible, (rep, last_step_df.SCount[1] / agentcount))
    end
    return fraction_still_susceptible
end

function decompose_adata(adata::DataFrames.DataFrame, config_key::Any)
    agent_attributes = adata |>
        @filter(_.step == 0) |>
        DataFrames.DataFrame
    @pipe agent_attributes |>
        select!(_, Not([:pos, :step, :socialnorm, :fear, :behavior, :quarantined, :state]))
    agent_attributes[!, :config] .= "config_" * lpad(config_key, 2, "0")
    @pipe adata |>
        select!(_, Not([:home, :neuroticism, :trust_authorities, :incubation_period, :infection_duration]))
    return agent_attributes, adata
end

function compute_summary_agent_states(; configs::Dict, path::String, write::Bool=false)
    summary_agent_states = init_summary_agent_states()
    progress_bar = ProgressMeter.Progress(length(keys(configs)), 0.2, "Computing summary agent states...")
    for config_key in keys(configs)
        agent_dynamics = Feather.read(
            joinpath(path, "config_" * lpad(config_key, 2, "0") * "_agent_dynamics.feather")
        )
        summary_config = summarize_agent_states_single_config(
            agent_dynamics=agent_dynamics, configs=configs, config_key=config_key
        )
        summary_agent_states = vcat(summary_agent_states, summary_config)
        ProgressMeter.next!(progress_bar)
    end
    if write
        write_dataframe(df=summary_agent_states, filename="summary_agent_states.feather", path=path)
    end
end

function init_summary_agent_states()
    return DataFrames.DataFrame(
        Config=String[],
        Replicate=Int64[],
        Step=Int64[],
        FearMean=Float64[],
        FearSE=Float64[],
        FearSD=Float64[],
        FearMin=Float64[],
        FearMax=Float64[],
        SocialNormMean=Float64[],
        SocialNormSE=Float64[],
        SocialNormSD=Float64[],
        SocialNormMin=Float64[],
        SocialNormMax=Float64[],
        BehaviorCount=Int64[]
    )
end

function summarize_agent_states_single_config(; agent_dynamics::DataFrames.DataFrame, configs::Dict, config_key::Any)
    summarized_config = @pipe agent_dynamics |>
        groupby(_, [:Step, :Replicate]) |>
        combine(
            _,
            :Fear => mean, :Fear => standard_error, :Fear => Statistics.std,
            :Fear => minimum, :Fear => maximum,
            :Socialnorm => mean, :Socialnorm => standard_error, :Socialnorm => Statistics.std,
            :Socialnorm => minimum, :Socialnorm => maximum,
            :Behavior => count_trues
        )
    summarized_config[!, :Config] .= "config_" * lpad(config_key, 2, "0")
    new_names = Dict(
        :Step => :Step, :Replicate => :Replicate,
        :Fear_mean => :FearMean,
        :Fear_standard_error => :FearSE, :Fear_std => :FearSD,
        :Fear_minimum => :FearMin, :Fear_maximum => :FearMax,
        :Socialnorm_mean => :SocialNormMean,
        :Socialnorm_standard_error => :SocialNormSE, :Socialnorm_std => :SocialNormSD,
        :Socialnorm_minimum => :SocialNormMin, :Socialnorm_maximum => :SocialNormMax,
        :Behavior_count_trues => :BehaviorCount
    )
    DataFrames.rename!(summarized_config, new_names)
    return summarized_config
end

function standard_error(x::AbstractArray)
    return Statistics.std(x) / sqrt(length(x))
end

function count_trues(x::AbstractArray)
    return sum(x)
end

function names_to_camelcase!(df::DataFrames.DataFrame)
    new_colnames = [to_camelcase(name) for name in names(df)]
    rename!(df, Symbol.(new_colnames))
    return df
end

function to_camelcase(varname::String)
	varname_split_titlecase = titlecase.(split(deepcopy(varname), "_"))
	varname_modified = join(varname_split_titlecase, "")
	return varname_modified
end
