extends Node2D
class_name TilemapManager

@export_group("Tilemap")
@export var tilemap : TileMapLayer;

enum TILES {RIVER, FOREST, HILL, GROVE, EMPTY};

func place_tile(tile_position : Vector2, atlas_coordinates : Vector2) :
	var source_id = tilemap.tile_set.get_source_id(0);
	tilemap.set_cell(tilemap.local_to_map(tile_position), source_id, atlas_coordinates);
