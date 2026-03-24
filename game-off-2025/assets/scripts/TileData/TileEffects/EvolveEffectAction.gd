class_name EvolveEffectAction extends EffectAction

func execute(tile_position : Vector2i, tile_data : CustomTileData):
	for offset_coords in tile_data.get_cells_in_range():
		var target_coordinates = tile_position + offset_coords;
		if !MainTilemap.instance.has_tile_at(target_coordinates): continue;
		
		await execute_evolve_effect(target_coordinates);

static func execute_evolve_effect(target_coordinates : Vector2i):
	var target_tile_data = MainTilemap.instance.tiles[target_coordinates];
	if target_tile_data.evolutions.is_empty(): return;
		
	var target_dynamic_tile_data = MainTilemap.instance.tiles_dynamic_data[target_coordinates];
	if target_dynamic_tile_data.base_tile.is_empty():
		target_dynamic_tile_data.base_tile = target_tile_data.id;
		
	var target_evolution = target_tile_data.evolutions[randi() % target_tile_data.evolutions.size()];
	await MainTilemap.instance.evolve_tile(target_coordinates, target_tile_data, target_evolution);

func get_description() -> String:
	return "evolves a tile in range.";
