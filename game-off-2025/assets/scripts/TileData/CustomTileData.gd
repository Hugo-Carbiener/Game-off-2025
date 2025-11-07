class_name CustomTileData

var name : String;
var damage : int;
var description : String;
var atlas_coordinates : Vector2;

static func create(_name : String, _damage : int, _description : String, _atlas_coordinates : Vector2) -> CustomTileData:
	var tile_data = CustomTileData.new();
	tile_data.name = _name;
	tile_data.damage = _damage;
	tile_data.description = _description;
	tile_data.atlas_coordinates = _atlas_coordinates;
	return tile_data;
