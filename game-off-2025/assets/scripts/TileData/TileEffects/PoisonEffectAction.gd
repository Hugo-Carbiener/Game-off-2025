class_name PoisonEffectAction extends EffectAction

func execute(tile_position : Vector2i, tile_data : CustomTileData):
	pass;

func get_description() -> String:
	return "applies poison for %s turns.";
