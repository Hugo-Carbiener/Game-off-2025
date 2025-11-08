extends DropReceiver
class_name TilemapDropReceiver

@onready var tilemap_manager = $"../../../Main tilemap"

func on_drop(control_dropped : Control):
	## place corresponding tile in the tilemap
	if control_dropped is not TileCard : return;
	
	var tile_data = TileDataManager.tile_dictionnary[control_dropped.card_name.text];
	var placed_tile = tilemap_manager.place_tile(tilemap_manager.get_local_mouse_position(), tile_data);
	if placed_tile:
		DragAndDropHandler.destroy_movable_copy();
		control_dropped.on_card_used();
		control_dropped.queue_free();
	else : 
		DragAndDropHandler.cancel_drag();
