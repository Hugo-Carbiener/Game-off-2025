extends CardInteractionManager
class_name CardSelector

static var instance : CardSelector;

var card_index_selected : int = -1;
var card_index_hovered : int = -1;

func _ready() -> void:
	if instance == null:
		instance = self;
	SignalBus.card_used.connect(on_card_used);

func on_card_selection():
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

func select_card(card_index : int):
	if cursor_preview != null:
		cursor_preview.queue_free();
	card_index_selected = card_index;
	
	var card_selected = get_selected_card();
	if card_selected == null: 
		card_index_selected = -1;
		return;
	
	SignalBus.card_selected.emit();
	card_selected.on_selection();
	cursor_preview = card_selected.card_sprite.duplicate();
	cursor_preview_anchor_offset = Vector2(card_selected.card_sprite.size.x/2, card_selected.card_sprite.global_position.y - card_selected.global_position.y);
	cursor_preview.position = get_local_mouse_position();
	get_tree().current_scene.add_child(cursor_preview);

func unselect_card():
	if !card_is_selected(): return;
	
	var selected_card = get_selected_card();
	if selected_card == null : return null;
	
	card_index_selected = -1;
	SignalBus.card_unselected.emit();
	selected_card.on_unselection();
	cursor_preview.queue_free();

func on_card_used(_tile_card : TileCard):
	unselect_card();

func get_selected_card() -> TileCard:
	if !card_is_selected() : return null;
	
	return TileCardFactory.instance.cards[card_index_selected];

func get_hovered_card() -> TileCard:
	if !card_is_hovered() : return null;
	
	return TileCardFactory.instance.cards[card_index_hovered];

func card_is_selected() -> bool:
	return card_index_selected != -1 and card_index_selected < TileCardFactory.instance.cards.size();

func card_is_hovered() -> bool:
	return card_index_hovered != -1 and card_index_hovered < TileCardFactory.instance.cards.size();
