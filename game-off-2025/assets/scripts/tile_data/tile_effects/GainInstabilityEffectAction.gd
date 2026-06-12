class_name GainInstabilityEffectAction extends EffectAction

func execute(tile_position : Vector2i, _tile_data : CustomTileData):
	if !MonsterFactory.breaches.has(tile_position):
		printerr("Attempt to execute breach effect on tile without breach " + str(tile_position));
		return;
	
	var breach = MonsterFactory.breaches[tile_position];
	breach.gain_instability(tile_effect.get_value(), tile_position);

func get_description() -> String:
	return "increases the breach's instability by %s.";
