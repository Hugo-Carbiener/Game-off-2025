class_name TriggerAllTilesEffectAction extends EffectAction

func execute(tile_position : Vector2i, tile_data : CustomTileData):
	for offset_coords in tile_data.get_cells_in_range():
		var target_coordinates = tile_position + offset_coords;
		if !MainTilemap.instance.has_tile_at(target_coordinates): continue;
		
		await TriggerRandomTileEffectAction.execute_tile_trigger_effect(target_coordinates);

func get_description() -> String:
	return "Triggers the effects of all tiles in range.";
