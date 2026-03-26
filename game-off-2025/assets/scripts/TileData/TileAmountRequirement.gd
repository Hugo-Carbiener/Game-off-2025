class_name TileAmountRequirement extends TileRequirement

var tile_amount : int
var possible_tiles : PackedStringArray;
var tile_range : int;

func _init(_tile_amount : int, _possible_tiles : PackedStringArray, _range : int):
	self.tile_amount = _tile_amount;
	self.possible_tiles = _possible_tiles;
	self.tile_range = _range;

static func parse(amount_string :String, possible_tiles_string : String, range_string : String) -> TileAmountRequirement:
	return TileAmountRequirement.new(int(amount_string), possible_tiles_string[1].split(Constants.TILE_REQUIREMENT_TILES_SEPARATOR), int(range_string));

func is_met(tilemap_position : Vector2i) -> bool:
	var offset_coordinates_list = MainTilemap.instance.get_neighbor_tile_coordinate_offset_within_range(tile_range);
	var counter = 0;
	for offset_coordinates in offset_coordinates_list:
		var tile_position_to_consider = tilemap_position + offset_coordinates;
		if !MainTilemap.instance.tiles.has(tile_position_to_consider): return false;
	
		var tile_to_consider = MainTilemap.instance.tiles[tile_position_to_consider];
		if possible_tiles.has(tile_to_consider.id):
			counter += 1;
	return counter >= tile_amount;

func has_requirement() -> bool:
	return tile_amount > 0 and possible_tiles != null and tile_range > 0;

func get_requirement() -> Dictionary[Vector2i, String]:
	var requirement : Dictionary[Vector2i, String];
	var possible_coordinates = MainTilemap.instance.get_neighbor_tile_coordinate_offset_within_range(tile_range);
	var random_base_index = randi() % possible_coordinates.size();
	for i in range(tile_amount):
		requirement.set(possible_coordinates[(random_base_index + i) % possible_coordinates.size()], possible_tiles[randi() % possible_tiles.size()]);
	return requirement;
