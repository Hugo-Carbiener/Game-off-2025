extends DropReceiver
class_name TilemapDropReceiver

@export var main_tilemap : MainTilemap;

func on_drop(control_dropped : Control):
	## place corresponding tile in the tilemap
	if control_dropped is not TileCard : return;
	
	var tile_data = TileDataManager.tile_dictionnary[DragAndDropHandler.dragged_control.card_id];
	var tile_position = main_tilemap.local_to_map(main_tilemap.get_local_mouse_position());
	var placed_tile = main_tilemap.place_tile(tile_position, tile_data);
	if placed_tile:
		# DragAndDropHandler.destroy_movable_copy();
		control_dropped.on_card_used(tile_position);
	else : 
		DragAndDropHandler.cancel_drag();
