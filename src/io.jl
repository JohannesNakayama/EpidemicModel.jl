function make_folders(batchname::String)
	if !("experiments" in readdir())
	    mkdir("experiments")
	end
	if !(batchname in readdir("experiments"))
	    mkdir(joinpath("experiments", batchname))
	end
end

function write_configs(; configs::Dict, path::String)
    open(joinpath(path, "configs.json"), "w") do file
        JSON.print(file, configs, 4)  # last parameter: indent by 4 spaces
    end
end

function write_dataframe(; df::DataFrames.DataFrame, filename::String, path::String)
    symbol_to_string!(df)
    if endswith(filename, ".feather")
        Feather.write(joinpath(path, filename), df)
    else
        Feather.write(joinpath(path, filename * ".feather"), df)
    end
end

function symbol_to_string!(df::DataFrames.DataFrame)
    for colname in DataFrames.names(df)
        if typeof(df[!, colname]) == Vector{Symbol}
            df[!, colname] = string.(df[!, colname])
        end
    end
    return df
end

function write_networks(networks::Dict; path::String, config_key::Int)
	for rep_key in keys(networks)
		graph_path = joinpath(
			path,
			"config_" * lpad(string(config_key), 2, "0")
			* "_rep_" * lpad(string(rep_key), 2, "0")
			* "_graph.txt"
		)
		LightGraphs.savegraph(graph_path, networks[rep_key], GraphIO.EdgeList.EdgeListFormat())
	end
end

function compress_data(; path::String, pattern::String, archive_filename::String)
	rawfiles_pattern = "*" * pattern
	cd(path)
	Base.run(`7z a -sdel -bb3 -mmt4 $archive_filename $rawfiles_pattern`)
	cd(joinpath("..", ".."))
end
