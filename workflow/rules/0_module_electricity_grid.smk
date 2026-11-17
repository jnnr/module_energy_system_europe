rule dummy_links:
    input:
        shapes="results/module_geo_boundaries/results/{shapes}/shapes.parquet"
    params:
        map_onshore_to_offshore=True,
    output:
        nodes="results/prepare/{shapes}/nodes.parquet",
        nodes_geo="results/prepare/{shapes}/nodes_geometries.parquet",
        links="results/prepare/{shapes}/links.parquet",
        links_geo="results/prepare/{shapes}/links_geometries.parquet",
        map_shapes_to_nodes="results/prepare/{shapes}/map_shapes_to_nodes.parquet",
    conda:
        "../envs/geo.yaml"
    script:
        "../scripts/dummy_electricity_grid.py"
