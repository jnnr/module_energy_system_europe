MODULE_NAME = "module_powerplants"
configfile: MODULE_CONFIG_DIR / f"{MODULE_NAME}.yaml"


module module_powerplants:
    snakefile:
        github(
            "calliope-project/module_powerplants",
            path="workflow/Snakefile",
            tag="v0.1.1",
        )
    pathvars:
        logs="results/module_powerplants/logs",
        resources="results/module_powerplants/resources",
        results="results/module_powerplants/results",
        shapes="results/module_geo_boundaries/results/{shapes}/shapes.parquet",
        proxy_rooftop_pv="results/module_area_potentials/results/{shapes}/reference/area_potential_pv_rooftop.tif",
        wemi="resources/user/wemi.xls",
    config: config[MODULE_NAME]

use rule * from module_powerplants as module_powerplants_*

rule prepare_powerplants:
    input:
        data="results/module_powerplants/results/{shape}/aggregated/adjusted/{category}.parquet",
        map_shapes_to_nodes="results/module_electricity_grid/{shape}/results/map_shapes_to_nodes.parquet",
        shapes="results/prepare/{shapes}/shapes.parquet",
    output:
        "results/prepare/{shape}/powerplants/powerplants_{category}.parquet"
    script: "../scripts/prepare_powerplants.py"

rule combine_powerplants:
    input:
        categories=expand(
            "results/prepare/{{shape}}/powerplants/powerplants_{category}.parquet",
            category=["bioenergy", "fossil", "geothermal", "hydropower", "nuclear", "wind"]
        ),
    output:
        "results/prepare/{shape}/powerplants_combined.parquet"
    script: "../scripts/combine_powerplants.py"

