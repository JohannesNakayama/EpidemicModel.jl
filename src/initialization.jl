function create_space(config::Config)
    base_space = LightGraphs.barabasi_albert(config.n_nodes, config.n0, config.k)
    for new_node in (config.n_nodes + 1):1:(config.n_nodes + config.agentcount)
        sampled_connection_node = StatsBase.sample(1:config.n_nodes)
        add_vertex!(base_space)
        add_edge!(base_space, new_node, sampled_connection_node)
    end
    return Agents.GraphSpace(base_space)
end

function initialize_model(config::Config, space::Agents.GraphSpace)
    properties = get_model_properties(config)
    model = Agents.AgentBasedModel(Citizen, space; properties=properties, scheduler=random_activation)
    add_public_spaces!(model, config.n_public_spaces)
    populate_space!(model, config.initial_infectives)
    initialize_statecounts!(model)
    return model
end

function get_model_properties(config::Config)
    return Dict(
        :agentcount => config.agentcount,
        :transmission_prob => config.transmission_prob,
        :test_prob => config.test_prob,
        :quarantine_duration => config.quarantine_duration,
        :behavior_reduction_factor => config.behavior_reduction_factor,
        :cost_matrix => (player1 = [1 3; 2 2], player2 = [1 2; 3 2]),
        :behavior_activated => config.behavior_activated,
        :authority_recommendation => 0.0,
        :tick_authority_recommendation => config.tick_authority_recommendation,
        :tick_authority_policy => config.tick_authority_policy,
        :homes => Int64[],
        :public_spaces => Int64[],
        :behavior_policy => false,
        :clock => 0,
        :S_count => config.agentcount,
        :E_count => 0,
        :Iu_count => 0,
        :Id_count => 0,
        :I_count => 0,
        :R_count => 0,
        :B_count => 0,
        :Id_cumulative => 0,
        :I_cumulative => 0,
        :new_cases_real => 0,
        :new_cases_detected => 0,
    )
end

function add_public_spaces!(model::Agents.ABM, n_public_spaces::Int64)
    degree_dict = Dict()
    for v in LightGraphs.vertices(model.space.graph)
        degree_dict[v] = LightGraphs.degree(model.space.graph, v)
    end
    vertices_by_degree = sort(collect(degree_dict), by=last, rev=true)
    for i in 1:n_public_spaces
        push!(model.public_spaces, popfirst!(vertices_by_degree)[1])
    end
    return model
end

function populate_space!(model::Agents.ABM, initial_infectives::Int64)
    highest_home = deepcopy(LightGraphs.nv(model.space.graph))
    lowest_home = highest_home - model.agentcount + 1
    positions_initial_infectives = StatsBase.sample(lowest_home:highest_home, initial_infectives)
    for (id, pos) in enumerate(collect(highest_home:-1:lowest_home))
        if !(pos in positions_initial_infectives)
            Agents.add_agent_pos!(Citizen(id, pos, :S), model)
            push!(model.homes, pos)
        else
            Agents.add_agent_pos!(Citizen(id, pos, :E), model)
            push!(model.homes, pos)
        end
    end
    return model
end

function initialize_statecounts!(model::Agents.ABM)
    model.S_count = sum([model.agents[i].state == :S for i in 1:model.agentcount])
    model.E_count = sum([model.agents[i].state == :E for i in 1:model.agentcount])
    model.I_count = deepcopy(model.E_count)
    model.I_cumulative = deepcopy(model.I_count)
    model.new_cases_real = deepcopy(model.I_count)
    return model
end
