extends Node2D
class_name TileRequirement

var relative_tilemap_coordinate : Vector2i;
var possible_tiles : PackedStringArray;

func is_met(tilemap_position : Vector2i) -> bool:
	var tile_position_to_consider = tilemap_position + relative_tilemap_coordinate;
	if !MainTilemap.instance.tiles.has(tile_position_to_consider): return false;
	
	var tile_to_consider = MainTilemap.instance.tiles[tile_position_to_consider];
	return possible_tiles.has(tile_to_consider.id);
