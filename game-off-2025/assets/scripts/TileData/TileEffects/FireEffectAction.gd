class_name FireEffectAction extends EffectAction

func execute(tile_position : Vector2i, tile_data : CustomTileData):
	pass;

func get_description() -> String:
	return "applies fire for %s turns.";
