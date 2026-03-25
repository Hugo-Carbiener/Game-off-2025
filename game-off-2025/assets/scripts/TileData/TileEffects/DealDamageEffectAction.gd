class_name DealDamageEffectAction extends EffectAction

func execute(tile_position : Vector2i, tile_data : CustomTileData):
	for offset_coords in tile_data.get_cells_in_range():
		if !MonsterFactory.monsters.has(tile_position + offset_coords): continue;
		
		MonsterFactory.monsters[tile_position + offset_coords].damage(tile_effect.get_value(), tile_position);

func get_description() -> String:
	return "deals %S damages.";
