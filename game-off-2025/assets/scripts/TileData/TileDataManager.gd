extends Node2D

const TILE_CUSTOM_DATA_NAME_KEY = "name";
const TILE_CUSTOM_DATA_DAMAGE_KEY = "damage";
const TILE_CUSTOM_DATA_DESCRIPTION_KEY = "description";

var tile_names : Array[String] = [];
var tile_damages = {"low" = 1, "medium" = 2, "high" = 3};
var tile_dictionnary : Dictionary[String, CustomTileData];

func load_tile_data(tilemap : TileMapLayer):
	var tileset = tilemap.tile_set;
	var source : TileSetAtlasSource = tileset.get_source(0);
	for tile_number in source.get_tiles_count():
		var atlas_coordinates = source.get_tile_id(tile_number);
		var tile_data = source.get_tile_data(atlas_coordinates, 0);
		var tile_name = tile_data.get_custom_data(TILE_CUSTOM_DATA_NAME_KEY);
		var tile_damage = tile_damages.get(tile_data.get_custom_data(TILE_CUSTOM_DATA_DAMAGE_KEY));
		var tile_description = tile_data.get_custom_data(TILE_CUSTOM_DATA_DESCRIPTION_KEY);
		var atlas_texture_coordinates = atlas_coordinates * source.texture_region_size;
		var custom_tile_data = CustomTileData.create(tile_name, tile_damage, tile_description, atlas_texture_coordinates);
		if tile_names.has(tile_name) or tile_dictionnary.has(custom_tile_data.name): 
			print("Error: tile " + tile_name + " registered twice");
			return
		
		tile_names.append(custom_tile_data.name);
		tile_dictionnary.set(custom_tile_data.name, custom_tile_data);
