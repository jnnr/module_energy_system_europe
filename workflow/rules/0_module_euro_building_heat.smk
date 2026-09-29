configfile: "config/modules/module_euro_building_heat.yaml"

MODULE_NAME = "module_euro_building_heat"


def config_module_euro_building_heat():
    module_config = config[MODULE_NAME]
    module_config["demand_years"]["start"] = config["year_start"]
    module_config["demand_years"]["end"] = config["year_end"]
    module_config["weather_years"]["start"] = config["year_start"]
    module_config["weather_years"]["end"] = config["year_end"]
    return module_config


module module_euro_building_heat:
    snakefile:
        github(
            "modelblocks-org/module_euro_building_heat",
            path="workflow/Snakefile",
            tag="v0.1.0"
        )
    pathvars: 
        logs="results/module_euro_building_heat/logs",
        resources="results/module_euro_building_heat/resources",
        results="results/module_euro_building_heat/results",
        shapes="results/module_geo_boundaries/results/{shapes}/shapes.parquet",
        edh_api="resources/user/module_euro_building_heat/edh_api_key.txt",
    config: config_module_euro_building_heat()

use rule * from module_euro_building_heat as module_euro_building_heat_*


SHAPES = [
    "NUTS0",
    "NUTS2",
]

rule all_euro_building_heat:
    input:
        expand("results/module_euro_building_heat/results/{shapes}/annual/heat_demand_twh.parquet", shapes=SHAPES),
        expand("results/module_euro_building_heat/results/{shapes}/hourly/heat_demand_mwh.parquet", shapes=SHAPES),
        expand("results/module_euro_building_heat/results/{shapes}/hourly/heat_pump_cop_pu.parquet", shapes=SHAPES),
        expand("results/module_euro_building_heat/results/{shapes}/hourly/heat_pump_electricity_demand_mwh.parquet", shapes=SHAPES),
