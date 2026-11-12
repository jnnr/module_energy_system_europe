MODULE_NAME = "module_geo_boundaries"
configfile: MODULE_CONFIG_DIR / f"{MODULE_NAME}.yaml"


module module_geo_boundaries:
    snakefile:
        github(
            "modelblocks-org/module_geo_boundaries",
            path="workflow/Snakefile",
            tag="v1.0.2",
        )
    config: config[MODULE_NAME]
    pathvars:
        logs="results/module_geo_boundaries/logs",
        resources="results/module_geo_boundaries/resources",
        results="results/module_geo_boundaries/results",

use rule * from module_geo_boundaries as module_geo_boundaries_*
