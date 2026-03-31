extends InteractionArea
class_name TilemapInteractionArea

@export var main_tilemap : MainTilemap;

func interact():
	## place corresponding tile in the tilemap
	var selected_card = CardSlotSelector.instance.get_selected_card();
	if selected_card == null: return false;
	
	var tile_data = TileDataManager.tile_dictionnary[selected_card.card_id];
	var tile_position = main_tilemap.local_to_map(main_tilemap.get_local_mouse_position());
	var placed_tile = await main_tilemap.place_tile(tile_position, tile_data);
	var keep_card_selected = true;
	
	if placed_tile:
		if TileCardFactory.instance.cards_amount[selected_card.card_id] == 1:
			CardSlotSelector.instance.unselect_card_slot();
			keep_card_selected = false;
		else: 
			keep_card_selected = true;
		selected_card.on_card_used();
	else: 
		
		keep_card_selected = false;
	
	if !keep_card_selected:
		CardSlotSelector.instance.unselect_card_slot();
