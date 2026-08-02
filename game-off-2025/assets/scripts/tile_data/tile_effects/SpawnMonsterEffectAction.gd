class_name SpawnMonsterEffectAction extends EffectAction

func execute(tile_position : Vector2i, _tile_data : CustomTileData):
	if !MonsterFactory.breaches.has(tile_position):
		printerr("Attempt to execute breach effect on tile without breach " + str(tile_position));
		return;
	
	var breach = MonsterFactory.breaches[tile_position];
	MonsterFactory.instance.spawn_monster(breach);

func get_description() -> String:
	return "spawns {value} monsters on the breach's weak points.";
