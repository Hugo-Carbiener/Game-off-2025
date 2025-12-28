extends InteractionArea
class_name TilemapInteractionArea

@export var main_tilemap : MainTilemap;

# depending on the remaining number of cards of the same type, the return value indicate if we can continue dropping more
func interact() -> bool:
	## place corresponding tile in the tilemap
	var selected_card = CardSlotSelector.instance.get_selected_card();
	if selected_card == null: return false;
	
	var tile_data = TileDataManager.instance.tile_dictionnary[selected_card.card_id];
	var tile_position = main_tilemap.local_to_map(main_tilemap.get_local_mouse_position());
	var placed_tile = main_tilemap.place_tile(tile_position, tile_data);
	var canContinue = true;
	
	if placed_tile:
		if TileCardFactory.instance.cards_amount[selected_card.card_id] == 1:
			CardSlotSelector.instance.unselect_card_slot();
			canContinue = false;
		else: 
			canContinue = true;
		selected_card.on_card_used(tile_position);
	else: 
		
		canContinue = false;
	
	return canContinue;
