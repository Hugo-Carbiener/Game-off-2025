class_name DevolveEffectAction extends EffectAction

func execute(tile_position : Vector2i, tile_data : CustomTileData):
	for offset_coords in tile_data.get_cells_in_range():
		var target_coordinates = tile_position + offset_coords;
		if !MainTilemap.instance.has_tile_at(target_coordinates): continue;
	
		var target_dynamic_tile_data = MainTilemap.instance.tiles_dynamic_data[target_coordinates];
		if target_dynamic_tile_data.previous_evolutions.is_empty(): continue;
		
		var target_tile_data = MainTilemap.instance.tiles[target_coordinates];
		var current_evolution_idx = target_dynamic_tile_data.previous_evolutions.find(target_tile_data.id);
		if current_evolution_idx == 0: continue;
		var target_evolution_idx = current_evolution_idx - 1 if current_evolution_idx > 0 else target_dynamic_tile_data.previous_evolutions.size() - 1;
		var target_evolution = target_dynamic_tile_data.previous_evolutions[target_evolution_idx];
		if target_dynamic_tile_data.base_tile.is_empty():
			target_dynamic_tile_data.base_tile = target_tile_data.id;
		
		await MainTilemap.instance.evolve_tile(target_coordinates, target_tile_data, TileDataManager.tile_dictionnary[target_evolution]);

func get_description() -> String:
	return "devolves a tile in range.";
