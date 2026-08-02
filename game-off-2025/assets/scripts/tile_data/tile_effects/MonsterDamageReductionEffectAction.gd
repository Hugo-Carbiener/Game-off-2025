class_name MonsterDamageReductionEffectAction extends EffectAction

func execute(tile_position : Vector2i, tile_data : CustomTileData):
	for offset_coords in tile_data.get_cells_in_range():
		if !MonsterFactory.monsters.has(tile_position + offset_coords): continue;
		
		MonsterFactory.monsters[tile_position + offset_coords].damage_weakness += tile_effect.get_value();

func get_description() -> String:
	return "enemies in range deal {value} less damage.";
