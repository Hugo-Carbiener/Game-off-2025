class_name MultiplyTileDamageEffectAction extends EffectAction

func execute(tile_position : Vector2i, tile_data : CustomTileData):
	for offset_coords in tile_data.get_cells_in_range():
		if !MainTilemap.instance.has_tile_at(tile_position + offset_coords): continue;
		
		MainTilemap.instance.tiles_dynamic_data[tile_position + offset_coords].damage_multiplier += tile_effect.get_value();

func get_description() -> String:
	return "multiply the damage of land tiles by %s.";
