function model_step!(model::Agents.ABM)
    model.new_cases_real = 0
    model.new_cases_detected = 0
    update_seir_states!(model)
    start_quarantines!(model)
    end_quarantines!(model)
    update_statecounts!(model)
    if model.behavior_activated
        update_authority_recommendation!(model)
        update_authority_policy!(model)
    end
    model.clock += 1
    return model
end

function update_seir_states!(model::Agents.ABM)
    for a in values(model.agents)
        advance_state_internal!(a, model)
    end
    for n in LightGraphs.vertices(model.space.graph)
        simulate_node_encounters!(model, n)
    end
    return model
end

function start_quarantines!(model::Agents.ABM)
    for a in values(model.agents)
        if a.quarantined & !(a.pos == a.home)
            Agents.move_agent!(a, a.home, model)
        end
    end
    return model
end

function end_quarantines!(model::Agents.ABM)
    for agent in values(model.agents)
        if agent.quarantined & (agent.ticks_quarantined >= model.quarantine_duration)
            agent.quarantined = false
        end
    end
    return model
end

function update_statecounts!(model::Agents.ABM)
    model.Id_cumulative = model.Id_cumulative + model.new_cases_detected
    model.I_cumulative = model.I_cumulative + model.new_cases_real
    model.S_count = sum([model.agents[i].state == :S for i in 1:model.agentcount])
    model.E_count = sum([model.agents[i].state == :E for i in 1:model.agentcount])
    model.Iu_count = sum([model.agents[i].state == :Iu for i in 1:model.agentcount])
    model.Id_count = sum([model.agents[i].state == :Id for i in 1:model.agentcount])
    model.I_count = model.E_count + model.Iu_count + model.Id_count
    model.R_count = sum([model.agents[i].state == :R for i in 1:model.agentcount])
    model.B_count = sum([model.agents[i].behavior for i in 1:model.agentcount])
    return model
end

function update_authority_recommendation!(model::Agents.ABM)
    if model.clock >= model.tick_authority_recommendation
        model.authority_recommendation = 1.0
    else
        model.authority_recommendation = 0.0
    end
    return model
end

function update_authority_policy!(model::Agents.ABM)
    if model.clock >= model.tick_authority_policy
        model.behavior_policy = true
    else
        model.behavior_policy = false
    end
    return model
end
