extends TileMapLayer
class_name TilemapManager

var source_id : int;
var tiles : Dictionary[Vector2i, CustomTileData];
static var instance : TilemapManager;

func _ready() -> void:
	if instance == null:
		instance = self;
	source_id = tile_set.get_source_id(0);
	init_world();

func place_tile(world_position : Vector2, tile : CustomTileData, force : bool = false) -> bool :
	var tile_position : Vector2i = local_to_map(world_position);
	if !force && !is_valid_cell(tile_position): return false;
	
	set_cell(tile_position, source_id, tile.atlas_coordinates);
	tiles.set(tile_position, tile);
	return true;

func init_tilemap_position():
	global_position += Vector2(DisplayServer.screen_get_size() / 2);

func init_world():
	place_tile(Vector2.ZERO, TileDataManager.tile_dictionnary["beacon"], true);
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
	if !cell_distance(coordinates, Vector2.ZERO) <= Constants.beacon_range:
		return false;
	
	if has_tile_at(coordinates) : return false;
	
	var has_neighbor = false;
	for neighbor_coordinates in get_surrounding_cells(coordinates):
		if has_tile_at(neighbor_coordinates): 
			has_neighbor = true;
			break;
	
	return has_neighbor;

func has_tile_at(coordinates : Vector2i) -> bool :
	return get_cell_source_id(coordinates) != -1 && tiles.has(coordinates);

func cell_distance(from : Vector2, to : Vector2) -> int:
	var vec_distance = abs(from - to);
	return floor(sqrt(pow(vec_distance.x, 2) + pow(vec_distance.y, 2)));

func cell_manhattan_distance(from : Vector2, to : Vector2) -> int:
	var vec_distance = abs(from - to);
	return vec_distance.x + vec_distance.y;

func get_random_tile_data(only_playable_tiles : bool) -> CustomTileData:
	var tiles_to_place = TileDataManager.playable_tiles if only_playable_tiles else TileDataManager.tiles;
	return TileDataManager.tile_dictionnary[tiles_to_place[randi() % tiles_to_place.size()]];

# Return an array of vectors describing the neighbor coordinates of a tile in (0, 0) within a given range
func get_neighbor_tile_coordinate_offset_within_range(tile_range : int) -> Array[Vector2i]:
	var neighbor_offset_coordinates : Array[Vector2i];
	var for_range = range(tile_range * -1, tile_range + 1);
	for x in for_range:
		for y in for_range:
			var coordinates = Vector2i(x, y);
			if coordinates == Vector2i.ZERO : continue;
			if cell_manhattan_distance(Vector2i.ZERO, coordinates) <= tile_range:
				neighbor_offset_coordinates.append(coordinates);
	return neighbor_offset_coordinates;

func get_valid_monster_spawn_positions() -> Array[Vector2i]:
	var monster_spawn_tile_range = Constants.monster_spawn_max_tile_distance;
	var neighbor_offsets_at_range = get_neighbor_tile_coordinate_offset_within_range(Constants.monster_spawn_max_tile_distance);
	var placed_cell_count = get_used_cells().size();
	var theoric_tile_range = min(placed_cell_count - 1, Constants.beacon_range) + monster_spawn_tile_range;
	var valid_spawns : Array[Vector2i];
	var for_range = range(theoric_tile_range * -1, theoric_tile_range + 1);
	for x in for_range:
		for y in for_range:
			var coordinates = Vector2i(x, y);
			if has_tile_at(coordinates) : continue;
			if MonsterFactory.instance.breaches.has(coordinates): continue;
			if MonsterFactory.instance.monsters.has(coordinates): continue;
			
			for neighbor_offset in neighbor_offsets_at_range:
				if has_tile_at(coordinates + neighbor_offset):
					valid_spawns.append(coordinates);
	return valid_spawns;
