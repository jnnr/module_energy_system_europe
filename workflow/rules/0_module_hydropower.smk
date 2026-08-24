configfile: "config/modules/module_hydropower.yaml"


module module_hydropower:
    pathvars:
        logs="resources/module_hydropower/logs",
        resources="resources/module_hydropower/resources",
        results="resources/module_hydropower/results",
        shapes="results/module_geo_boundaries/results/{shapes}/shapes.parquet",
        powerplants="results/module_powerplants/{shapes}/powerplants.parquet",
    snakefile:
        github(
            "modelblocks-org/module_hydropower",
            path="workflow/Snakefile",
            tag="v0.2.2",
        )
    config:
        config["module_hydropower"]

rule all_hydropower:
    message: "Prepare all results of module_hydropower."
    input:
        expand("results/module_hydropower/{shapes}/statistics/generation.parquet", shapes=["NUTS0"]),
        expand("results/module_hydropower/{shapes}/disaggregated/inflow_mwh.parquet", shapes=["NUTS0"]),
        expand("results/module_hydropower/{shapes}/aggregated/{plant_type}_inflow_pu.parquet", shapes=["NUTS0"], plant_type=["run_of_river", "reservoir"]),