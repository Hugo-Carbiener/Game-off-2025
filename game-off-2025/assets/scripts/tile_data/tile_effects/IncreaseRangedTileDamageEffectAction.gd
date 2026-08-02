class_name IncreaseRangedTileDamageEffectAction extends EffectAction

func execute(tile_position : Vector2i, tile_data : CustomTileData):
	for offset_coords in tile_data.get_cells_in_range():
		if !MainTilemap.instance.has_tile_at(tile_position + offset_coords): continue;
		
		var target_tile_data = MainTilemap.instance.tiles[tile_position + offset_coords];
		if target_tile_data.effect_range.is_ranged(): 
			MainTilemap.instance.tiles_dynamic_data[tile_position + offset_coords].damage_boost += tile_effect.get_value();

func get_description() -> String:
	return "increase the damage of ranged land tiles by {value}.";
