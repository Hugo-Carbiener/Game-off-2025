extends InteractionArea
class_name TilemapInteractionArea

## Describes an Interaction Area that holds the main tilemap. 
##
## On click, a tile is placed if the cell is valid and if a card is currently selected, otherwise we select the cell. 

@export var main_tilemap : MainTilemap;

func interact():
	var selected_card = CardSelector.instance.get_selected_card();
	if selected_card != null: 
		place_tile(selected_card);
	else:
		select_tile();

func place_tile(selected_card : TileCard):
	var tile_data = TileDataManager.tile_dictionnary[selected_card.card_id];
	var tile_position = main_tilemap.local_to_map(main_tilemap.get_local_mouse_position());
	var placed_tile = await main_tilemap.place_tile(tile_position, tile_data);
	SignalBus.card_used.emit(selected_card);
	
	if !placed_tile:
		CardSelector.instance.unselect_card();

func select_tile():
	TileSelector.instance.on_tile_selection_interaction();
