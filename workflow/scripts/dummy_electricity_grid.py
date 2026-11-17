
# %%
"""Link all those locations that are neighbours."""
# Adapted from https://github.com/calliope-project/euro-calliope/blob/develop/scripts/transmission/template_transmission.py
import geopandas as gpd
import networkx as nx
import pandas as pd
from shapely.geometry import LineString
from shapely.prepared import prep
#%%

K_EDGE_CONNECTION = (
    1  # every component of the graph is connect with at least this amount of edges
)

def construct_nodes(shapes, map_shapes_to_nodes, crs="EPSG:3035"):
    source_crs = shapes.crs
    df = pd.merge(
        shapes,
        map_shapes_to_nodes,
        on="shape_id"
    )
    df = df.loc[df["shape_class"] == "land"]
    df = df[["nodes", "geometry"]]
    df = df.to_crs(crs)
    df["geometry"] = df["geometry"].centroid
    df = df.to_crs(source_crs)
    return df

def construct_map_shapes_to_nodes(shapes):
    """Map shape_id to the nodes."""
    map_shapes_to_nodes = shapes.copy()
    def _get_node_id(row):
        """Get everything after _to_ in the shape_id, if _to_ is present, else return the shape_id."""
        if "_to_" in row["shape_id"]:
            return row["shape_id"].split("_to_")[1]
        else:
            return row["shape_id"]
    map_shapes_to_nodes["nodes"] = map_shapes_to_nodes.apply(_get_node_id, axis=1)
    map_shapes_to_nodes = map_shapes_to_nodes[["shape_id", "nodes"]]
    return map_shapes_to_nodes


def construct_techs_and_links(
    shapes, sea_connections
):
    """Link all those locations that are neighbours."""
    _shapes = shapes.to_crs("EPSG:3035").set_index("shape_id").sort_index()
    graph = _create_graph_with_land_connections(_shapes)
    if sea_connections:
        graph.add_edges_from([(loc1, loc2) for loc1, loc2 in sea_connections])

    # assert nx.is_connected(graph), "There are electrical islands in the network graph."
    def _get_centroid(id_node):
        centroid = _shapes.to_crs("EPSG:4326").loc[id_node].geometry.centroid
        return centroid.x, centroid.y

    geometry = [LineString([_get_centroid(from_node), _get_centroid(to_node)]) for from_node, to_node in graph.edges]
    links = gpd.GeoDataFrame(index=graph.edges, data=None, geometry=geometry, crs="EPSG:4326")

    # calliope-specific
    links.index.names = ["link_from", "link_to"]
    links = links.reset_index()
    links = links.apply(order_nodes, axis=1)
    links["techs"] = links.apply(lambda x: f"{x['link_from']}_to_{x['link_to']}", axis=1)
    links.loc[:, "distance"] = links.to_crs("EPSG:3035").geometry.length
    links["flow_cap_min"] = 0

    return links


def order_nodes(row: pd.Series) -> pd.Series:
    """Order buses so that bus0 is alphabetically first."""
    if row["link_from"] > row["link_to"]:
        row["link_from"], row["link_to"] = row["link_to"], row["link_from"]
    return row


def _create_graph_with_land_connections(shapes):
    graph = nx.Graph()
    graph.add_nodes_from([
        (region_id, {"centroid": region_centroid})
        for region_id, region_centroid in shapes.centroid.to_dict().items()
    ])
    neighbours = {
        index: _neighbours(region.geometry, index, shapes)
        for index, region in shapes.iterrows()
    }
    graph.add_edges_from([
        (region, other)
        for region, all_others in neighbours.items()
        for other in all_others
    ])
    return graph


def _neighbours(region_geometry, region_index, regions):
    region_geometry = prep(region_geometry)
    return [
        other_index
        for other_index, other_region in regions.iterrows()
        if (other_index != region_index)
        and region_geometry.intersects(other_region.geometry)
    ]


def main(
    input_shapes,
    output_nodes,
    output_nodes_geo,
    output_links,
    output_links_geo,
    output_map_shapes_to_nodes,
):
    shapes = gpd.read_parquet(input_shapes)

    map_shapes_to_nodes = construct_map_shapes_to_nodes(shapes)
    map_shapes_to_nodes.to_parquet(output_map_shapes_to_nodes)

    nodes_geo = construct_nodes(
        shapes=shapes,
        map_shapes_to_nodes=map_shapes_to_nodes,
    )
    nodes_geo.to_parquet(output_nodes_geo)
    nodes_geo.to_parquet(output_nodes)

    links_geo = construct_techs_and_links(
        shapes=shapes.loc[shapes["shape_class"] == "land"],
        sea_connections=[],
    )
    links_geo.to_parquet(output_links_geo)
    links_geo.to_parquet(output_links)


if __name__ == "__main__":
    main(
        input_shapes=snakemake.input.shapes,
        output_nodes=snakemake.output.nodes,
        output_nodes_geo=snakemake.output.nodes_geo,
        output_links=snakemake.output.links,
        output_links_geo=snakemake.output.links_geo,
        output_map_shapes_to_nodes=snakemake.output.map_shapes_to_nodes,
    )

#%%
class attributes:
    def __init__(self, **kwargs):
        for key, value in kwargs.items():
            setattr(self, key, value)

class mock_snakemake:
    input = attributes(
        shapes = "../../results/module_geo_boundaries/results/ESP_PRT_NUTS2/shapes.parquet"

    )
    output = attributes(
        nodes="workflow/tests/data/nodes.parquet",
        nodes_geo="workflow/tests/data/nodes.geojson",
        links="workflow/tests/data/links.parquet",
        links_geo="workflow/tests/data/links.geojson",
        map_shapes_to_nodes="workflow/tests/data/map_shapes_to_nodes.parquet",
    )
# snakemake = mock_snakemake() 

input_shapes=snakemake.input.shapes
output_nodes=snakemake.output.nodes
output_nodes_geo=snakemake.output.nodes_geo
output_links=snakemake.output.links
output_links_geo=snakemake.output.links_geo
output_map_shapes_to_nodes=snakemake.output.map_shapes_to_nodes


shapes = gpd.read_parquet(input_shapes)
map_shapes_to_nodes = construct_map_shapes_to_nodes(shapes)

nodes_geo = construct_nodes(
    shapes=shapes,
    map_shapes_to_nodes=construct_map_shapes_to_nodes(shapes),
)

links_geo = construct_techs_and_links(
    shapes=shapes,
    sea_connections=[],
)
links_geo

#%%

