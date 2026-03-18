class_name BeaconHealEffectAction extends EffectAction

func execute(_tile_position : Vector2i, _tile_data : CustomTileData):
	BeaconManager.instance.heal(tile_effect.get_value());

func get_description() -> String:
	return "heals the beacon for %s health points.";
