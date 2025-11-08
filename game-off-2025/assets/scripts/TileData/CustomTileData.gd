class_name CustomTileData

var name : String;
var damage : int;
var description : String;
var atlas_coordinates : Vector2;
var atlas_texture_coordinates : Vector2;
var is_playable : bool;

static func create(_name : String, 
		_damage : int, 
		_description : String, 
		_atlas_coordinates : Vector2, 
		_atlas_texture_coordinates : Vector2, 
		_is_playable : bool) -> CustomTileData:
	var tile_data = CustomTileData.new();
	tile_data.name = _name;
	tile_data.damage = _damage;
	tile_data.description = _description;
	tile_data.atlas_coordinates = _atlas_coordinates;
	tile_data.atlas_texture_coordinates = _atlas_texture_coordinates;
	tile_data.is_playable = _is_playable;
	return tile_data;
