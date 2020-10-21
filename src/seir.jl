function advance_state_internal!(agent::Agents.AbstractAgent, model::Agents.ABM)
    if agent.quarantined
        agent.ticks_quarantined += 1
    end
    if (agent.state == :Iu) | (agent.state == :Id)
        agent.ticks_infected += 1
    end
    if (agent.state == :E)
        if (agent.ticks_exposed >= agent.incubation_period)
            agent.state = :Iu
            agent.ticks_infected = 1
            return agent
        end
        agent.ticks_exposed += 1
    end
    if ((agent.state == :Iu) | (agent.state == :Id)) & (agent.ticks_infected >= agent.infection_duration)
        agent.state = :R
        return agent
    end
    if (agent.state == :Iu) & (agent.ticks_infected % 10 == 0) & (agent.ticks_infected < agent.infection_duration)
        if Random.rand() < model.test_prob
            agent.state = :Id
            model.new_cases_detected += 1
            agent.quarantined = true
            agent.ticks_quarantined = 1
        end
        return agent
    end
    return agent
end

function simulate_node_encounters!(model::Agents.ABM, node::Int64)
    encounters = Agents.get_node_agents(node, model)
    for candidate in encounters
        for interaction_partner in encounters
            adequate_contact!(candidate, interaction_partner, model)
        end
    end
    return model
end

function adequate_contact!(agent::Agents.AbstractAgent, encounter::Agents.AbstractAgent, model::Agents.ABM)
    if (agent.state == :S) & ((encounter.state == :Iu) | (encounter.state == :Id))
        get_exposed!(agent, model)
    end
    return agent
end

function get_exposed!(agent::Agents.AbstractAgent, model::Agents.ABM)
    if agent.behavior
        if Random.rand() < (model.transmission_prob * model.behavior_reduction_factor)
            agent.state = :E
            model.new_cases_real += 1
            agent.ticks_exposed = 1
        end
    else
        if Random.rand() < model.transmission_prob
            agent.state = :E
            model.new_cases_real += 1
            agent.ticks_exposed = 1
        end
    end
    return agent
end
