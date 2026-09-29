configfile: "config/modules/module_demand_electricity.yaml"

MODULE_NAME = "module_demand_electricity"


def config_module_demand_electricity():
    module_config = config[MODULE_NAME]
    def to_YYYY_MM_DD(year):
        return f"{year}-01-01"
    module_config["temporal_scope"]["start"] = to_YYYY_MM_DD(config["year_start"])
    module_config["temporal_scope"]["end"] = to_YYYY_MM_DD(config["year_end"])
    module_config["temporal_scope"]["frequency"] = config["temporal_resolution"]
    return module_config


module module_demand_electricity:
    snakefile:
        github(
            "modelblocks-org/module_demand_electricity",
            path="workflow/Snakefile",
            tag="v0.2.0"
        )
    pathvars: 
        logs="results/module_demand_electricity/logs",
        resources="results/module_demand_electricity/resources",
        results="results/module_demand_electricity/results",
        shapes="results/module_geo_boundaries/results/{shape}/shapes.parquet",
        token_entsoe="resources/user/module_demand_electricity/token_entsoe.txt"
    config: config_module_demand_electricity()

use rule * from module_demand_electricity as module_demand_electricity_*



rule copy_token_entsoe:
    input:
        ".secrets/entsoe.txt"
    output:
        "results/module_demand_electricity/resources/user/token_entsoe.txt"
    conda: "../envs/shell.yaml"
    shell:
        "cp {input} {output}"

rule prepare_demand_electricity:
    input:
        data="results/module_demand_electricity/results/demand_electricity_{shape}_MW.parquet",
        map_shapes_to_nodes="results/module_electricity_grid/{shape}/results/map_shapes_to_nodes.parquet",
    output:
        "results/prepare/{shape}/demand_electricity_MW.parquet"
    run:
        import pandas as pd
        from lib.data_processing import map_index
        data = pd.read_parquet(input.data)
        map_shapes_to_nodes = pd.read_parquet(input.map_shapes_to_nodes)
        map_shapes_to_nodes = dict(map_shapes_to_nodes.set_index("shape_id")["nodes"])
        data = map_index(data, map_shapes_to_nodes, axis=1)
        data = data.rename(columns={"shape_id": "nodes"})
        data.to_parquet(output[0])

rule all_demand_electricity:
    input:
        expand(
            "results/module_demand_electricity/results/{shape}/demand_electricity_MW.parquet",
            shape=["NUTS0", "NUTS2", "NUTS3"],
        )
