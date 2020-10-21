# EpidemicModel.jl

Simulation of an epidemic in a heterogeneous agent population to explore the effects of different mitigative measures such as recommendations, policies as well as individual mitigative behaviors such as mask wearing. 


## Prerequesites

This model was build in Julia 1.4.2. It depends on the third-party Julia packages `Agents.jl`, `DataFrames.jl`, `LightGraphs.jl`, `StatsBase.jl`, `Feather.jl`, `JSON.jl`, `Distributions.jl`, `GraphIO.jl`, `Pipe.jl`, `Query.jl` and `ProgressMeter.jl` which can be installed directly from within the Julia package manager Pkg.jl. To switch to package manager, enter `]` into the REPL. To install packages, enter the following code (ommitting the `.jl`):

```
(@v1.4) pkg> add <PACKAGE_NAME>
```

A further requirement is the file archiver [7-zip](https://7-zip.org/). 7-zip needs to be in the local PATH variable. To test whether 7-zip is properly setup, run the command `7z` in a terminal.

You can test if the code runs by executing the test script:

```
julia>include("test_module.jl")
```


## Usage

To reproduce my Master thesis experiments, execute the following:

```
julia>include("experiments.jl")
```

This will run all simulations that are setup in the scripts in the `config` folder. Please be advised to only run this script if you have enough storage on your device. Even though the data is compressed by the module, the simulations create a substantial amount of data.