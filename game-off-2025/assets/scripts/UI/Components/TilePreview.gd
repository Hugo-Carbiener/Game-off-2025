class_name TilePreview extends TextureRect

const tile_preview_scene : PackedScene = preload("res://scenes/components/TilePreview.tscn");

static func create_tile_preview(tile_data : CustomTileData) -> TilePreview:
	var tile_preview = tile_preview_scene.instantiate();
	tile_preview.texture = tile_preview.texture.duplicate();
	tile_preview.texture.region = tile_data.get_texture_region();
	return tile_preview;
