class_name DrainedEffectAction extends EffectAction

func execute(_tile_position : Vector2i, _tile_data : CustomTileData):
	pass;

func get_description() -> String:
	return "This tile is drained from void energy and when destroyed, this card is not discarded.";
