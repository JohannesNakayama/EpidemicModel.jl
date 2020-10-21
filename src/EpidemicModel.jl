module EpidemicModel

    using Agents
    using DataFrames
    using LightGraphs
    using Random
    using StatsBase
    using Feather
    using JSON
    using Distributions
    using GraphIO
    using Distributed
    using Pipe
    using Query
    using Statistics
    using ProgressMeter

    include("citizen.jl")
    include("config.jl")
    include("initialization.jl")
    include("seir.jl")
    include("agent_step.jl")
    include("model_step.jl")
    include("formatting.jl")
    include("simulation.jl")
    include("io.jl")

    export Config
    export initialize_model
    export run_model!
    export run_experiment
    export write_dataframe
    export write_configs
    export write_networks
    export compress_data

end
