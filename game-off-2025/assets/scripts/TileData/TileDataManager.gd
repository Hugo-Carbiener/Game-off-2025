extends Node2D

const TILE_CUSTOM_DATA_NAME_KEY = "name";
const TILE_CUSTOM_DATA_DAMAGE_KEY = "damage";
const TILE_CUSTOM_DATA_DESCRIPTION_KEY = "description";
const TILE_CUSTOM_DATA_PLAYABLE_KEY = "is_playable";

const tile_set: TileSet = preload("res://assets/tiles/tiles_8px.tres");

var tiles : Array[String] = [];
var playable_tiles : Array[String] = [];
var tile_damages = {"none" = 0, "low" = 1, "medium" = 2, "high" = 3};
var tile_dictionnary : Dictionary[String, CustomTileData];
var tile_size : Vector2i;

func _ready() -> void:
	load_tile_data();

func load_tile_data():
	var source : TileSetAtlasSource = tile_set.get_source(0);
	tile_size = source.texture_region_size;
	for tile_number in source.get_tiles_count():
		var atlas_coordinates = source.get_tile_id(tile_number);
		var tile_data = source.get_tile_data(atlas_coordinates, 0);
		var tile_name = tile_data.get_custom_data(TILE_CUSTOM_DATA_NAME_KEY);
		var tile_damage = tile_damages.get(tile_data.get_custom_data(TILE_CUSTOM_DATA_DAMAGE_KEY));
		var tile_description = tile_data.get_custom_data(TILE_CUSTOM_DATA_DESCRIPTION_KEY);
		var is_playable = tile_data.get_custom_data(TILE_CUSTOM_DATA_PLAYABLE_KEY);
		var atlas_texture_coordinates = atlas_coordinates * tile_size;
		var custom_tile_data = CustomTileData.create(tile_name, 
			tile_damage, 
			tile_description, 
			atlas_coordinates,
			atlas_texture_coordinates, 
			is_playable);
		if tiles.has(tile_name) or tile_dictionnary.has(custom_tile_data.name): 
			print("Error: tile " + tile_name + " registered twice");
			return
		
		if is_playable:
			playable_tiles.append(custom_tile_data.name);
		tiles.append(custom_tile_data.name);
		tile_dictionnary.set(custom_tile_data.name, custom_tile_data);

func get_random_tile_data(only_playable_tiles : bool) -> CustomTileData:
	var tiles_to_place = playable_tiles if only_playable_tiles else tiles;
	return tile_dictionnary[tiles_to_place[randi() % tiles_to_place.size()]];
