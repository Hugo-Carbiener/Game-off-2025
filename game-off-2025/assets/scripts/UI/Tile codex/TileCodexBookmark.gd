extends TextureButton
class_name TileCodexBookmark

const bookmark_scene: PackedScene = preload("res://scenes/Tile codex/TileCodexBookmark.tscn");

@export var icon : TextureRect;

static func create_tile_codex_bookmark(target_tile_id: String) -> TileCodexBookmark:
	var bookmark = bookmark_scene.instantiate();
	bookmark.setup(target_tile_id);
	return bookmark;

func setup(target_tile_id: String):
	var tile_data = TileDataManager.instance.tile_dictionnary[target_tile_id];
	if tile_data == null:
		printerr("Failed to find tile data " + target_tile_id + " while instancing tile codex bookmark.");
		return;
	
	icon.texture.region = tile_data.get_texture_region();
	button_up.connect(on_click.bind(target_tile_id));

func on_click(target_tile_id: String):
	SignalBus.bookmark_clicked.emit(target_tile_id);
