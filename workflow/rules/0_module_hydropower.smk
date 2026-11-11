MODULE_NAME = "module_hydropower"


def config_module_hydropower():
    module_config = copy.deepcopy(config[MODULE_NAME])
    module_config["years"]["start"] = config["year_start"]
    module_config["years"]["end"] = config["year_end"]
    return module_config


module module_hydropower:
    pathvars:
        logs="results/module_hydropower/logs",
        resources="results/module_hydropower/resources",
        results="results/module_hydropower/results",
        shapes="results/module_geo_boundaries/results/{shapes}/shapes.parquet",
        powerplants="results/module_powerplants/results/{shapes}/powerplants/adjusted/hydropower.parquet",
    snakefile:
        github(
            "modelblocks-org/module_hydropower",
            path="workflow/Snakefile",
            tag="v0.2.2",
        )
    config:
        config_module_hydropower()


use rule * from module_hydropower as module_hydropower_*
