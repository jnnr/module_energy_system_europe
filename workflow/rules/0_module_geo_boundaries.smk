configfile: "config/modules/module_geo_boundaries.yaml"


module module_geo_boundaries:
    snakefile:
        github(
            "calliope-project/module_geo_boundaries",
            path="workflow/Snakefile",
            tag="v1.0.1",
        )
    config: config["module_geo_boundaries"]
    prefix:
        "results/module_geo_boundaries"

use rule * from module_geo_boundaries as module_geo_boundaries_*


rule all_geo_boundaries:
    message: "Request outputs"
    input:
        "results/module_geo_boundaries/results/NUTS0/shapes.parquet",
        # "results/module_geo_boundaries/results/NUTS2/shapes.parquet",
        # "results/module_geo_boundaries/results/NUTS3/shapes.parquet",
