function agent_step!(agent::Agents.AbstractAgent, model::Agents.ABM)
    if !agent.quarantined
        if model.clock % 10 != 0
            move_agent_random!(agent, model)
        else
            move_agent_home!(agent, model)
        end
    end
    update_fear!(agent, model)
    if model.behavior_activated
        update_socialnorm_memory!(agent, model)
        if model.clock % 10 == 0
            update_socialnorm!(agent, model)
            choose_strategy!(agent, model)
        end
        if model.behavior_policy
            adapt_to_policy!(agent, model)
        end
    end
    return agent
end

function move_agent_random!(agent::Agents.AbstractAgent, model::Agents.ABM)
    adjacent_places = setdiff(node_neighbors(agent.pos, model), model.homes)
    new_position = StatsBase.sample(adjacent_places)
    Agents.move_agent!(agent, new_position, model)
    return agent
end

function move_agent_home!(agent::Agents.AbstractAgent, model::Agents.ABM)
    Agents.move_agent!(agent, agent.home, model)
    return agent
end

function update_fear!(agent::Agents.AbstractAgent, model::Agents.ABM)
    incidence_influence = model.Id_count / model.agentcount
    for i in 1:10
        if Random.rand() < agent.neuroticism
            incidence_influence = pump(incidence_influence)
        end
    end
    agent.fear = StatsBase.mean([agent.fear, incidence_influence])
    return agent
end

function pump(x)
    return tanh(x) / tanh(1)
end

function update_socialnorm_memory!(agent::Agents.AbstractAgent, model::Agents.ABM)
    neighbor_behavior = [
        i.behavior
        for i in Agents.get_node_agents(agent.pos, model)
        if !(i === agent)
    ]
    if length(neighbor_behavior) > 0
        append!(
            agent.socialnorm_memory,
            neighbor_behavior
        )
    end
    return agent
end

function update_socialnorm!(agent::Agents.AbstractAgent, model::Agents.ABM)
    if length(agent.socialnorm_memory) > 0
        agent.socialnorm = StatsBase.mean(agent.socialnorm_memory)
    end
    agent.socialnorm_memory = Any[]
    return agent
end

function choose_strategy!(agent::Agents.AbstractAgent, model::Agents.ABM)
    weight = compute_weight(agent, model)
    costmatrix = compute_costmatrix(weight, model)
    if (b_is_dominant(costmatrix))
        agent.behavior = true
        agent.behavior_buffer = true
    elseif (notb_is_dominant(costmatrix))
        agent.behavior = false
        agent.behavior_buffer = false
    else
        agent.behavior = biased_coin(weight)
        agent.behavior_buffer = copy(agent.behavior)
    end
    return agent
end

function compute_weight(agent::Agents.AbstractAgent, model::Agents.ABM)
    return StatsBase.mean([
        agent.fear,
        agent.socialnorm,
        agent.trust_authorities * model.authority_recommendation
    ])
end

function compute_costmatrix(weight::Float64, model::Agents.ABM)
    costmatrix = (
        [(1 - weight) (1 - weight); weight weight]
        .* model.cost_matrix.player1
    )
    return costmatrix
end

function b_is_dominant(costmatrix::AbstractArray)
    is_dominant = (
        (costmatrix[1, 1] < costmatrix[2, 1])
        & (costmatrix[1, 2] < costmatrix[2, 2])
    )
    return is_dominant
end

function notb_is_dominant(costmatrix::AbstractArray)
    is_dominant = (
        (costmatrix[1, 1] > costmatrix[2, 1])
        & (costmatrix[1, 2] > costmatrix[2, 2])
    )
    return is_dominant
end

function biased_coin(weight::Float64)
    return Random.rand() < weight ? true : false
end

function adapt_to_policy!(agent::Agents.AbstractAgent, model::Agents.ABM)
    if agent.pos in model.public_spaces
        agent.behavior = true
    else
        agent.behavior = copy(agent.behavior_buffer)
    end
    return agent
end
