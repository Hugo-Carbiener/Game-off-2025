class_name BeaconShieldEffectAction extends EffectAction

func execute(tile_position : Vector2i, tile_data : CustomTileData):
	pass;

func get_description() -> String:
	return "shields the beacon for the turn for %s shield points.";
