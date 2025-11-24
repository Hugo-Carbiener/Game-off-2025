extends TileMapLayer
class_name TilemapManager

var source_id : int;
var tiles : Dictionary[Vector2i, CustomTileData];
var terrain_id_by_cell : Dictionary[Vector2i, int];

func _ready() -> void:
	position = get_viewport().get_visible_rect().size * Constants.tilemap_offset;
	source_id = tile_set.get_source_id(0);

func place_tile(tile_position : Vector2i, tile : CustomTileData, force : bool = false) -> bool :
	if !force && !is_valid_cell(tile_position): return false;
	
	set_cell(tile_position, source_id, tile.atlas_coordinates);
	update_terrain_tiles(tile_position);
	tiles.set(tile_position, tile);
	return true;

func clear_tile(tile_position : Vector2i):
	set_cell(tile_position, 0, Vector2i.ONE * -1);
	tiles.erase(tile_position);
	terrain_id_by_cell.erase(tile_position);

func clear_tilemap():
	clear();
	tiles.clear();
	terrain_id_by_cell.clear();

func is_valid_cell(_coordinates : Vector2) -> bool:
	return true;

func has_tile_at(coordinates : Vector2i) -> bool :
	return get_cell_source_id(coordinates) != -1 && tiles.has(coordinates);

func cell_distance(from : Vector2, to : Vector2) -> int:
	var vec_distance = abs(from - to);
	return floor(sqrt(pow(vec_distance.x, 2) + pow(vec_distance.y, 2)));

func cell_manhattan_distance(from : Vector2, to : Vector2) -> int:
	var vec_distance = abs(from - to);
	return vec_distance.x + vec_distance.y;

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

func get_cell_by_terrain(terrain_id : int) -> Array[Vector2i]:
	var cells : Array[Vector2i];
	for cell in terrain_id_by_cell.keys():
		if terrain_id_by_cell.get(cell) == terrain_id:
			cells.append(cell);
	return cells;

func update_terrain_tiles(tilemap_position : Vector2i):
	var source : TileSetAtlasSource = tile_set.get_source(source_id);
	var tile_data = source.get_tile_data(get_cell_atlas_coords(tilemap_position), 0);
	var terrain_set = tile_data.terrain_set;
	var terrain_id = tile_data.terrain;
	
	if terrain_id != -1:
		terrain_id_by_cell.set(tilemap_position, terrain_id);
		set_cells_terrain_connect(get_cell_by_terrain(terrain_id), terrain_set, terrain_id)
