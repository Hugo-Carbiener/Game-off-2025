extends CardInteractionManager
class_name CardSlotSelector

static var instance : CardSlotSelector;

var card_slot_selected : int = -1;
var card_slot_hovered : int = -1;

func _ready() -> void:
	super();
	if instance == null:
		instance = self;

func on_card_slot_input():
	var interaction_area = get_interaction_area_on_cursor();
	if interaction_area == null:
		unselect_card_slot();
		return;
	
	var keep_card = interaction_area.interact();
	if !keep_card : 
		unselect_card_slot();

func on_card_slot_selection():
	if !card_is_hovered(): 
		unselect_card_slot();
		return;
	
	if !card_is_selected():
		select_card_slot(card_slot_hovered);
		return;
	
	if card_slot_selected != card_slot_hovered:
		unselect_card_slot();
		select_card_slot(card_slot_hovered);
	else :
		unselect_card_slot();

func on_card_slot_selection_via_key(card_slot_index : int):
	if !card_is_selected():
		select_card_slot(card_slot_index);
		return;

	if card_slot_selected != card_slot_index:
		unselect_card_slot();
		select_card_slot(card_slot_index);
	else :
		unselect_card_slot();

func select_card_slot(card_slot_index : int):
	if cursor_preview != null:
		cursor_preview.queue_free();
	card_slot_selected = card_slot_index;
	
	var card_selected = get_selected_card();
	if card_selected == null: 
		card_slot_selected = -1;
		return;
	
	card_selected.on_selection();
	IndicationTilemap.instance.on_card_selection();
	cursor_preview = card_selected.card_sprite.duplicate();
	cursor_preview_anchor_offset = Vector2(card_selected.card_sprite.size.x/2, card_selected.card_sprite.global_position.y - card_selected.global_position.y);
	cursor_preview.position = get_local_mouse_position();
	get_tree().current_scene.add_child(cursor_preview);

func unselect_card_slot():
	if !card_is_selected(): return;
	
	var selected_card = get_selected_card();
	if selected_card == null : return null;
	
	card_slot_selected = -1;
	IndicationTilemap.instance.on_card_unselection();
	selected_card.on_unselection();
	cursor_preview.queue_free();

func get_selected_card() -> TileCard:
	if !card_is_selected() : return null;
	
	var card_id = TileCardFactory.instance.slots_per_card.find_key(card_slot_selected);
	if card_id == null : return null;
	return TileCardFactory.instance.cards[card_id];

func get_hovered_card() -> TileCard:
	if !card_is_hovered() : return null;
	
	return TileCardFactory.instance.cards[TileCardFactory.instance.slots_per_card.find_key(card_slot_hovered)];

func card_is_selected() -> bool:
	return card_slot_selected != -1 and card_slot_selected < Constants.card_slot_amount;

func card_is_hovered() -> bool:
	return card_slot_hovered != -1 and card_slot_hovered < Constants.card_slot_amount;
