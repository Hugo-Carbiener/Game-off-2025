class_name PlaceTileEffectAction extends EffectAction

func execute(tile_position : Vector2i, tile_data : CustomTileData):
	var target_tile = TileDataManager.tile_dictionnary[tile_effect.get_tile_value()];
	if target_tile == null: return;
	
	var valid_cells : Array[Vector2i];
	for offset_coords in tile_data.get_cells_in_range():
		var target_coordinates = tile_position + offset_coords;
		if MainTilemap.instance.has_tile_at(target_coordinates): continue;
		
		valid_cells.append(target_coordinates);
	
	if valid_cells.is_empty(): return;
	
	MainTilemap.instance.place_tile(valid_cells[randi() % valid_cells.size()], target_tile, true);

func get_description() -> String:
	return "place a {tile_value} tile.";
