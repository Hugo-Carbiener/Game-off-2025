extends CardInteractionManager
class_name CardSelector

static var instance : CardSelector;

var card_index_selected : int = -1;
var cards_selected : Array[TileCard];
var card_index_hovered : int = -1;

func _ready() -> void:
	if instance == null:
		instance = self;
	SignalBus.card_discarded.connect(on_card_discarded);

func on_card_selection_interaction():
	if !card_is_hovered(): 
		unselect_card();
		return;
	
	if !card_is_selected():
		select_card(card_index_hovered);
		return;
	
	if card_index_selected != card_index_hovered:
		unselect_card();
		select_card(card_index_hovered);
	else :
		unselect_card();

func on_multi_card_selection_interaction():
	if !card_is_hovered(): 
		return;
	
	var hovered_card = get_hovered_card();
	if cards_selected.has(hovered_card):
		cards_selected.erase(hovered_card);
		hovered_card.on_unselection();
	else :
		multi_select_card(hovered_card);

func select_card(card_index : int):
	card_index_selected = card_index;
	
	var card_selected = get_selected_card();
	if card_selected == null: 
		card_index_selected = -1;
		return;
	
	SignalBus.card_selected.emit();
	card_selected.on_selection();
	
	var tile_data = TileDataManager.tile_dictionnary[card_selected.card_id];
	if tile_data == null: return;
	
	cursor_preview.texture.region = tile_data.get_texture_region();
	cursor_preview_anchor_offset = Vector2(card_selected.card_sprite.size.x/2, card_selected.card_sprite.global_position.y - card_selected.global_position.y);
	cursor_preview.position = get_local_mouse_position();
	cursor_preview.visible = true;

func multi_select_card(tile_card : TileCard):
	cards_selected.append(tile_card);
	SignalBus.card_multi_selected.emit();
	tile_card.on_selection();

func unselect_card():
	if !card_is_selected(): return;
	
	var selected_card = get_selected_card();
	card_index_selected = -1;
	if selected_card != null :
		selected_card.on_unselection();
	
	SignalBus.card_unselected.emit();
	cursor_preview.visible = false;

func on_card_discarded(_tile_card : TileCard):
	if _tile_card == get_selected_card():
		unselect_card();

func clear_multi_card_selection():
	cards_selected.clear();

func get_selected_card() -> TileCard:
	if !card_is_selected() : return null;
	
	return TileCardFactory.instance.cards[card_index_selected];

func get_hovered_card() -> TileCard:
	if !card_is_hovered() : return null;
	
	return TileCardFactory.instance.cards[card_index_hovered];

func card_is_selected() -> bool:
	return card_index_selected != -1 and card_index_selected < TileCardFactory.instance.get_hand_size();

func card_is_hovered() -> bool:
	return card_index_hovered != -1 and card_index_hovered < TileCardFactory.instance.get_hand_size();
