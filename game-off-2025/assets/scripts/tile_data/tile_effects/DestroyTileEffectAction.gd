class_name DestroyTileEffectAction extends EffectAction

func execute(tile_position : Vector2i, _tile_data : CustomTileData):
	MainTilemap.instance.clear_tile(tile_position);

func get_description() -> String:
	return "removes a tile in range.";
