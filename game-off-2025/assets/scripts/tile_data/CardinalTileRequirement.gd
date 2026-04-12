class_name CardinalTileRequirement extends TileRequirement

var relative_tilemap_coordinates : Vector2i;
var possible_tiles : PackedStringArray;

func _init(_relative_tilemap_coordinates : Vector2i, _possible_tiles : PackedStringArray):
	self.relative_tilemap_coordinates = _relative_tilemap_coordinates;
	self.possible_tiles = _possible_tiles;

static func parse(cardinal_point_string : String, possible_tiles_string : String) -> CardinalTileRequirement:
	var target_coordinates : Vector2i = Vector2i.ZERO;
	for cardinal_direction in cardinal_point_string.split():
		target_coordinates += Constants.NEIGHBOR_TILE_COORDINATES_CODEX[cardinal_direction];
	return CardinalTileRequirement.new(target_coordinates, possible_tiles_string.split(Constants.TILE_REQUIREMENT_TILES_SEPARATOR));


func is_met(tilemap_position : Vector2i) -> bool:
	var tile_position_to_consider = tilemap_position + relative_tilemap_coordinates;
	if !MainTilemap.instance.tiles.has(tile_position_to_consider): return false;
	
	var tile_to_consider = MainTilemap.instance.tiles[tile_position_to_consider];
	return possible_tiles.has(tile_to_consider.id);

func has_requirement() -> bool:
	return relative_tilemap_coordinates != null and possible_tiles != null;

func get_requirement() -> Dictionary[Vector2i, String]:
	return {relative_tilemap_coordinates: possible_tiles[randi() % possible_tiles.size()]};
