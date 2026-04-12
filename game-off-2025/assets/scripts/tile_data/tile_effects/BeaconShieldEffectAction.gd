class_name BeaconShieldEffectAction extends EffectAction

func execute(_tile_position : Vector2i, _tile_data : CustomTileData):
	BeaconManager.instance.add_shield(tile_effect.get_value());

func get_description() -> String:
	return "shields the beacon for the turn for %s shield points.";
