extends Node2D

const TILE_CUSTOM_DATA_ID_KEY = "id";
const TILE_CUSTOM_DATA_COLOR_KEY = "color";
const TILE_CUSTOM_DATA_NAME_KEY = "name";
const TILE_CUSTOM_DATA_DAMAGE_KEY = "damage";
const TILE_CUSTOM_DATA_RANGE_KEY = "range";
const TILE_CUSTOM_DATA_NATURAL_COST_KEY = "natural_cost";
const TILE_CUSTOM_DATA_MINERAL_COST_KEY = "mineral_cost";
const TILE_CUSTOM_DATA_ARTIFICIAL_COST_KEY = "artificial_cost";
const TILE_CUSTOM_DATA_DESCRIPTION_KEY = "description";
const TILE_CUSTOM_DATA_PLAYABLE_KEY = "is_playable";
const TILE_CUSTOM_DATA_UTIL_KEY = "is_util";
const TILE_CUSTOM_DATA_EVOLUTIONS_KEY = "evolutions";
const TILE_CUSTOM_DATA_REQUIREMENTS_KEY = "requirements";
const TILE_CUSTOM_DATA_EFFECTS_KEY = "effects";
const tile_set: TileSet = preload("res://assets/tiles/tiles_8px.tres");

static var beacon_icon : Texture2D = preload("res://assets/sprites/UI_beacon.png");
static var damage_icon_small : Texture2D = preload("res://assets/sprites/UI_damage-icon-small.png");
static var ranged_damage_icon_small : Texture2D = preload("res://assets/sprites/UI_ranged_damage_icon_small.png");
static var beacon_icon_small : Texture2D = preload("res://assets/sprites/UI_beacon_icon_small.png");
static var heal_icon_small : Texture2D = preload("res://assets/sprites/UI_heal_icon_small.png");
static var burst_icon_small : Texture2D = preload("res://assets/sprites/UI_burst_icon_small.png");
static var essence_icons : Dictionary[BIOMES, Texture2D] = {
	 BIOMES.NATURAL : preload("res://assets/sprites/UI_natural_essence.png"),
	 BIOMES.MINERAL : preload("res://assets/sprites/UI_mineral_essence.png"),
	 BIOMES.ARTIFICIAL : preload("res://assets/sprites/UI_artificial_essence.png")
}

## tiles 
var tile_dictionnary : Dictionary[String, CustomTileData];
var playable_tiles : Array[String];
var land_tiles : Array[String];
var tile_size : Vector2i;
var world_tile_amount = 0;

enum TRIGGERS {
	ANY,
	ON_MONSTER_WALK,
	ON_SETUP_START,
	ON_RESOLUTION_START,
	ON_RESOLUTION_END,
	ON_MONSTER_DEATH,
	ON_TILE_PLACED,
	ON_TILE_DESTROYED,
	ON_BEACON_DAMAGE,
	ON_BREACH_INTERACTION,
}

enum BIOMES {
	NATURAL,
	MINERAL,
	ARTIFICIAL
}

var biome_colors : Dictionary[BIOMES, Color] = {
	BIOMES.NATURAL : Color.SEA_GREEN,
	BIOMES.MINERAL : Color.STEEL_BLUE,
	BIOMES.ARTIFICIAL : Color.ORANGE_RED
}

# regex 
var cardinal_tile_requirement_regex : RegEx = RegEx.new();
var tile_amount_requirement_regex : RegEx = RegEx.new();

func _ready() -> void:
	load_regexes();
	load_tile_data();
	load_devolutions();

func load_regexes():
	cardinal_tile_requirement_regex.compile("^([NESW]{1,2})=((?:\\w+,?)+)$");
	tile_amount_requirement_regex.compile("^(\\d+)((?:\\w+-?,?)+)(\\d+)$");

func load_tile_data():
	var source : TileSetAtlasSource = tile_set.get_source(0);
	tile_size = source.texture_region_size;
	for tile_number in source.get_tiles_count():
		var atlas_coordinates = source.get_tile_id(tile_number);
		var tile_data = source.get_tile_data(atlas_coordinates, 0);
		var tile_id = tile_data.get_custom_data(TILE_CUSTOM_DATA_ID_KEY);
		var tile_color = tile_data.get_custom_data(TILE_CUSTOM_DATA_COLOR_KEY);
		var tile_name = tile_data.get_custom_data(TILE_CUSTOM_DATA_NAME_KEY);
		var tile_cost = TileCost.new(tile_data.get_custom_data(TILE_CUSTOM_DATA_NATURAL_COST_KEY),
			tile_data.get_custom_data(TILE_CUSTOM_DATA_MINERAL_COST_KEY),
			tile_data.get_custom_data(TILE_CUSTOM_DATA_ARTIFICIAL_COST_KEY));
		var tile_damage = tile_data.get_custom_data(TILE_CUSTOM_DATA_DAMAGE_KEY);
		var tile_range = tile_data.get_custom_data(TILE_CUSTOM_DATA_RANGE_KEY);
		var tile_description = tile_data.get_custom_data(TILE_CUSTOM_DATA_DESCRIPTION_KEY);
		var is_playable = tile_data.get_custom_data(TILE_CUSTOM_DATA_PLAYABLE_KEY);
		var is_util = tile_data.get_custom_data(TILE_CUSTOM_DATA_UTIL_KEY);
		var atlas_texture_coordinates = atlas_coordinates * tile_size;
		var evolutions = tile_data.get_custom_data(TILE_CUSTOM_DATA_EVOLUTIONS_KEY);
		var requirements = tile_data.get_custom_data(TILE_CUSTOM_DATA_REQUIREMENTS_KEY);
		var effects = tile_data.get_custom_data(TILE_CUSTOM_DATA_EFFECTS_KEY);
		var custom_tile_data = CustomTileData.new(
			tile_id,
			tile_color,
			tile_name,
			tile_cost,
			tile_damage,
			tile_range,
			tile_description,
			atlas_coordinates,
			atlas_texture_coordinates,
			is_playable,
			is_util,
			evolutions,
			requirements,
			effects);
		if tile_dictionnary.has(custom_tile_data.id): 
			printerr("Error: tile " + tile_id + " registered twice");
			return
		

		if is_playable:
			playable_tiles.append(custom_tile_data.id);
			if !UserData.get_known_tiles().has(custom_tile_data.id):
				UserData.get_known_tiles().append(custom_tile_data.id);
		if !is_util:
			land_tiles.append(custom_tile_data.id);
		tile_dictionnary.set(custom_tile_data.id, custom_tile_data);

func load_devolutions():
	for tile_data in tile_dictionnary.values():
		for devolution_candidate in tile_dictionnary.values():
			if devolution_candidate.evolutions.has(tile_data.id):
				tile_data.devolutions.append(devolution_candidate.id);

func learn_evolution(tile_data : CustomTileData):
	if UserData.get_known_tiles().has(tile_data.id): return;
	
	CardSelector.instance.unselect_card();
	UserData.get_known_tiles().append(tile_data.id);
	HandPile.instance.update_tile_card_evolutions();
	CardSelector.instance.unselect_card();
	NotificationCenter.instance.notify_new_tile(tile_data);
	TileCodex.store_new_tile(tile_data.id);
