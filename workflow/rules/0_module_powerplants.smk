configfile: "config/modules/module_powerplants.yaml"

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
        proxy_rooftop_pv="results/module_area_potentials/results/NUTS0/area_potential_pv_rooftop.tif",
        wemi="resources/user/wemi.xls",
    config: config["module_powerplants"]

use rule * from module_powerplants as module_powerplants_*


rule all_powerplants:
    message: "Prepare all powerplants data."
    default_target: True
    input:
        expand(
            "results/module_powerplants/results/{shapes}/aggregated/{adjustment}/{category}.parquet", 
            shapes=["NUTS0", "NUTS2", "NUTS3"],
            adjustment=["adjusted"], # TODO add "unadjusted"
            category=["bioenergy", "fossil", "geothermal", "hydropower", "nuclear", "wind", "solar"]  # "large_solar"
        )

rule prepare_powerplants:
    input:
        data="results/module_powerplants/results/{shape}/aggregated/adjusted/{category}.parquet",
        map_shapes_to_nodes="results/module_electricity_grid/{shape}/results/map_shapes_to_nodes.parquet",
        shapes="results/prepare/{shape}/shapes.parquet",
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

