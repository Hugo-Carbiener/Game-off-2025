class_name TriggerRandomTileEffectAction extends EffectAction

func execute(tile_position : Vector2i, tile_data : CustomTileData):
	var valid_cells : Array[Vector2i];
	for offset_coords in tile_data.get_cells_in_range():
		var target_coordinates = tile_position + offset_coords;
		if !MainTilemap.instance.has_tile_at(target_coordinates): continue;
		
		var target_tile_data = MainTilemap.instance.tiles[target_coordinates];
		if target_tile_data.effects.is_empty(): continue;
		
		valid_cells.append(target_coordinates);
	
	if valid_cells.is_empty(): return;
	
	await execute_tile_trigger_effect(valid_cells[randi() % valid_cells.size()]);

static func execute_tile_trigger_effect(target_tile_position : Vector2i):
	var target_tile_data = MainTilemap.instance.tiles[target_tile_position];
	if target_tile_data == null or target_tile_data.effects.is_empty(): return;
	
	for effect in target_tile_data.effects:
		if effect is TriggerRandomTileEffectAction \
			or effect is TriggerRandomTileEffectAction: continue;
			
		await effect.execute(TileDataManager.TRIGGERS.ANY, target_tile_position, target_tile_data);

func get_description() -> String:
	return "Triggers the effects of a random tile in range.";
