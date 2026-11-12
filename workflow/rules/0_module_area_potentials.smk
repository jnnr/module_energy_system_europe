MODULE_NAME = "module_area_potentials"
configfile: MODULE_CONFIG_DIR / f"{MODULE_NAME}.yaml"


module module_area_potentials:
    snakefile:
        github(
            "modelblocks-org/module_area_potentials",
            path="workflow/Snakefile",
            tag="v2.0.0",
        )
    pathvars:
        results="results/module_area_potentials/results",
        resources="results/module_area_potentials/resources",
        logs="results/module_area_potentials/logs",
        shapes="results/module_geo_boundaries/results/{shape}/shapes.parquet",
        wdpa="resources/user/module_area_potentials/WDPA/wdpa.gdb",
    config: config[MODULE_NAME]


use rule * from module_area_potentials as module_area_potentials_*

rule area_potentials_all:
    message:
        "Run the module."
    input:
        "results/module_area_potentials/results/NUTS0/reference/area_potential_report.html",
        "results/module_area_potentials/results/NUTS0/sens/area_potential_report.html",

rule all_area_potentials:
    message: "Prepare all area potentials data."
    input:
        expand(
            "results/module_area_potentials/results/NUTS0/reference/area_potential_{tech}.tif",
            tech=["wind_onshore", "wind_offshore", "pv_open_field", "pv_rooftop"]
        )

rule aggregate_raster_to_poly:
    input:
        raster="results/module_area_potentials/results/{shape}/reference/area_potential_{tech}.tif",
        polygons="results/prepare/{shape}/shapes.parquet",
    output: "results/prepare/{shape}/area_potentials/reference/area_potential_{tech}.parquet"
    shell: "python scripts/aggregate_raster_to_poly.py {input.raster} {input.polygons} {output[0]}"

# rule prepare_power_potential:
#     input:
#         area_potential="results/prepare/{shape}/area_potentials/area_potential_{tech}.parquet",
#         power_densities="data/prepare/power_densities/power_densities.csv",
#         shapes="results/prepare/{shape}/shapes.parquet",
#         map_shapes_to_nodes="results/module_electricity_grid/{shape}/results/map_shapes_to_nodes.parquet",
#     output:
#        "results/prepare/{shape}/power_potentials/power_potential_{tech}.parquet",
#     script: "../scripts/prepare_power_potential.py"

# rule combine_power_potentials:
#     input:
#         expand(
#             "results/prepare/{{shape}}/power_potentials/power_potential_{tech}.parquet",
#             tech=["pv_rooftop", "pv_open_field", "wind_onshore", "wind_offshore"]
#         )
#     output:
#         "results/prepare/{shape}/power_potentials_combined.parquet",
#     script: "../scripts/combine_power_potentials.py"
