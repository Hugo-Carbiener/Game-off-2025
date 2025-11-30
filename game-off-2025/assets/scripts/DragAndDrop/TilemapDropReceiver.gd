extends DropReceiver
class_name TilemapDropReceiver

@export var main_tilemap : MainTilemap;

# depending on the remaining number of cards of the same type, the return value indicate if we can continue dropping more
func on_drop(control_dropped : Control) -> bool:
	## place corresponding tile in the tilemap
	if control_dropped is not TileCard : return false;
	
	var tile_data = TileDataManager.instance.tile_dictionnary[DragAndDropHandler.instance.dragged_control.card_id];
	var tile_position = main_tilemap.local_to_map(main_tilemap.get_local_mouse_position());
	var placed_tile = main_tilemap.place_tile(tile_position, tile_data);
	
	var canContinue = true;
	
	if placed_tile:
		if TileCardFactory.instance.cards_amount[DragAndDropHandler.instance.dragged_control.card_id] == 1:
			DragAndDropHandler.instance.cancel_drag();
			canContinue = false;
		else: 
			canContinue = true;
		control_dropped.on_card_used(tile_position);
	else: 
		canContinue = false;
	
	return canContinue;
