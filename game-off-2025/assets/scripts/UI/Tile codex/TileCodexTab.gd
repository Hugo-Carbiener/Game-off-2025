extends Control
class_name TileCodexTab

const tile_codex_tab_scene: PackedScene = preload("res://scenes/Tile codex/TileCodexTab.tscn");

@export var button : TextureButton;
@export var icon : TextureRect;

static func create_tile_codex_tab(target_tile_id: String) -> TileCodexTab:
	var tab = tile_codex_tab_scene.instantiate();
	tab.setup(target_tile_id);
	return tab;

func setup(target_tile_id: String):
	var tile_data = TileDataManager.instance.tile_dictionnary[target_tile_id];
	if tile_data == null:
		printerr("Failed to find tile data " + target_tile_id + " while instancing tile codex tab.");
		return;
	icon.texture = AtlasTexture.new();
	icon.texture.region = tile_data.get_texture_region();
	# TODO: link button to tile codex.
