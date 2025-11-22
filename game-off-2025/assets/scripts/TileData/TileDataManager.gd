extends Node2D

const TILE_CUSTOM_DATA_ID_KEY = "id";
const TILE_CUSTOM_DATA_COLOR_KEY = "color";
const TILE_CUSTOM_DATA_NAME_KEY = "name";
const TILE_CUSTOM_DATA_DAMAGE_KEY = "damage";
const TILE_CUSTOM_DATA_FATIGUE_KEY = "fatigue";
const TILE_CUSTOM_DATA_DESCRIPTION_KEY = "description";
const TILE_CUSTOM_DATA_PLAYABLE_KEY = "is_playable";
const TILE_CUSTOM_DATA_EVOLUTIONS_KEY = "evolutions";
const TILE_CUSTOM_DATA_REQUIREMENTS_KEY = "requirements";
const TILE_CUSTOM_DATA_ACTIONS_KEY = "actions";
const tile_set: TileSet = preload("res://assets/tiles/tiles_8px.tres");

## tile stats
const tile_damages = {"none" = 0, "low" = 1, "medium" = 2, "high" = 3};
const tile_fatigues = {"none" = 0, "low" = 1, "medium" = 2, "high" = 3};
## tile actions
enum TRIGGERS {
	ON_TILE_ENTER,
	ON_NEIGHBOR_TILE_ENTER,
	ON_TILE_LEAVE,
	ON_NEIGHBOR_TILE_LEAVE,
	ON_TILE_STAY,
	ON_NEIGHBOR_TILE_STAY
};
const trigger_to_neighbor_trigger = {
	TRIGGERS.ON_TILE_ENTER : TRIGGERS.ON_NEIGHBOR_TILE_ENTER,
	TRIGGERS.ON_TILE_LEAVE : TRIGGERS.ON_NEIGHBOR_TILE_LEAVE,
	TRIGGERS.ON_TILE_STAY : TRIGGERS.ON_NEIGHBOR_TILE_STAY
}
const trigger_alias = {
	"OTE" = TRIGGERS.ON_TILE_ENTER, 
	"ONTE" = TRIGGERS.ON_NEIGHBOR_TILE_ENTER, 
	"OTL" = TRIGGERS.ON_TILE_LEAVE, 
	"ONTL" = TRIGGERS.ON_NEIGHBOR_TILE_LEAVE, 
	"OTS" = TRIGGERS.ON_TILE_LEAVE,
	"ONTS" = TRIGGERS.ON_NEIGHBOR_TILE_STAY
};
## tiles 
var tile_dictionnary : Dictionary[String, CustomTileData];
var tiles : Array[String] = [];
var playable_tiles : Array[String] = [];
var tile_size : Vector2i;

func _ready() -> void:
	load_tile_data();

func load_tile_data():
	var source : TileSetAtlasSource = tile_set.get_source(0);
	tile_size = source.texture_region_size;
	for tile_number in source.get_tiles_count():
		var atlas_coordinates = source.get_tile_id(tile_number);
		var tile_data = source.get_tile_data(atlas_coordinates, 0);
		var tile_id = tile_data.get_custom_data(TILE_CUSTOM_DATA_ID_KEY);
		var tile_color = tile_data.get_custom_data(TILE_CUSTOM_DATA_COLOR_KEY);
		var tile_name = tile_data.get_custom_data(TILE_CUSTOM_DATA_NAME_KEY);
		var tile_damage = tile_damages.get(tile_data.get_custom_data(TILE_CUSTOM_DATA_DAMAGE_KEY));
		var tile_fatigue = tile_fatigues.get(tile_data.get_custom_data(TILE_CUSTOM_DATA_FATIGUE_KEY));
		var tile_description = tile_data.get_custom_data(TILE_CUSTOM_DATA_DESCRIPTION_KEY);
		var is_playable = tile_data.get_custom_data(TILE_CUSTOM_DATA_PLAYABLE_KEY);
		var atlas_texture_coordinates = atlas_coordinates * tile_size;
		var evolutions = tile_data.get_custom_data(TILE_CUSTOM_DATA_EVOLUTIONS_KEY);
		var requirements = tile_data.get_custom_data(TILE_CUSTOM_DATA_REQUIREMENTS_KEY);
		var actions = tile_data.get_custom_data(TILE_CUSTOM_DATA_ACTIONS_KEY);
		var custom_tile_data = CustomTileData.new(
			tile_id,
			tile_color,
			tile_name,
			tile_damage,
			tile_fatigue,
			tile_description,
			atlas_coordinates,
			atlas_texture_coordinates,
			is_playable,
			evolutions,
			requirements,
			actions);
		if tiles.has(tile_id) or tile_dictionnary.has(custom_tile_data.id): 
			print("Error: tile " + tile_id + " registered twice");
			return
		
		if is_playable:
			playable_tiles.append(custom_tile_data.id);
		tiles.append(custom_tile_data.id);
		tile_dictionnary.set(custom_tile_data.id, custom_tile_data);

func get_random_tile_data(only_playable_tiles : bool) -> CustomTileData:
	var tiles_to_place = playable_tiles if only_playable_tiles else tiles;
	return tile_dictionnary[tiles_to_place[randi() % tiles_to_place.size()]];
