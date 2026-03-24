class_name FillWithTileEffectAction extends EffectAction

func execute(tile_position : Vector2i, tile_data : CustomTileData):
	var target_tile = TileDataManager.tile_dictionnary[tile_effect.get_tile_value()];
	if target_tile == null: return;
	
	for offset_coords in tile_data.get_cells_in_range():
		var target_coordinates = tile_position + offset_coords;
		if MainTilemap.instance.has_tile_at(target_coordinates): continue;
		
		MainTilemap.instance.place_tile(target_coordinates, target_tile, true);

func get_description() -> String:
	return "fills the area with %s tiles.";
