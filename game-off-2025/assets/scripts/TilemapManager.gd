extends TileMapLayer
class_name TilemapManager

@export var beacon_range : int;
var source_id : int;

func _ready() -> void:
	source_id = tile_set.get_source_id(0);
	TileDataManager.load_tile_data(self);
	init_world();

func place_tile(world_position : Vector2, tile : CustomTileData) -> bool :
	var tile_position : Vector2i = local_to_map(world_position);
	if !is_valid_cell(tile_position): return false;
	
	set_cell(tile_position, source_id, tile.atlas_coordinates);
	return true;

func init_tilemap_position():
	global_position += Vector2(DisplayServer.screen_get_size() / 2);

func init_world():
	set_cell(Vector2.ZERO, source_id, TileDataManager.tile_dictionnary["beacon"].atlas_coordinates);
	#for x in range(-50 , 51, 1):
		#for y in range(-50, 51, 1):
			#var coords = Vector2(x, y);
			#if x == 0 and y == 0 : 
				#continue;
			#if !is_valid_cell(coords) :
				#continue;
			#var tile_data = get_random_tile_data(true);
			#set_cell(coords, source_id, tile_data.atlas_coordinates);

func is_valid_cell(coordinates : Vector2) -> bool:
	if !cell_distance(coordinates, Vector2.ZERO) <= beacon_range:
		return false;
	
	if has_tile_at(coordinates) : return false;
	
	for neighbor_coordinates in get_surrounding_cells(coordinates):
		if has_tile_at(neighbor_coordinates): 
			return true;
	
	return false;

func has_tile_at(coordinates : Vector2i) -> bool :
	return get_cell_source_id(coordinates) != -1;

func cell_distance(from : Vector2, to : Vector2) -> int:
	var vec_distance = abs(from - to);
	return floor(sqrt(pow(vec_distance.x, 2) + pow(vec_distance.y, 2)));

func get_random_tile_data(only_playable_tiles : bool) -> CustomTileData:
	var tiles = TileDataManager.playable_tiles if only_playable_tiles else TileDataManager.tiles;
	return TileDataManager.tile_dictionnary[tiles[randi() % tiles.size()]];
