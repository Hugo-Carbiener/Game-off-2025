class_name DiscardWindow extends Control

const TITLE = "Choose %s cards to discard";

@export_group("Components")
@export var title_label : Label;
@export var card_container : CardSelectionInteractionArea;
@export var card_amount_label : Label;
@export var validate_button : TextureButton;

var target_card_amount : int;

func _ready() -> void:
	if !validate_button.button_up.has_connections():
		validate_button.button_up.connect(validate);
	SignalBus.card_multi_selected.connect(update_components);

func setup(card_amount : int, card_hand : Array[TileCard]):
	target_card_amount = card_amount;
	title_label.text = TITLE % str(target_card_amount);
	for tile_card in card_hand:
		tile_card.reparent(card_container, false);
	update_components();
	visible = true;
	ClickManager.interaction_areas.push_front(card_container);

func reset():
	visible = false;
	ClickManager.interaction_areas.erase(card_container);

func update_components():
	var selected_card_amount = CardSelector.instance.cards_selected.size();
	var is_selection_valid = selected_card_amount == target_card_amount;
	validate_button.disabled = !is_selection_valid;
	validate_button.modulate = Color.WHITE if is_selection_valid else Color.DIM_GRAY;
	card_amount_label.text = str(selected_card_amount) + "/" + str(target_card_amount);
	card_amount_label.modulate = Color.WHITE if is_selection_valid else Color.CRIMSON;

func validate():
	reset();
	for tile_card in card_container.get_children():
		tile_card.reparent(TileCardFactory.instance, false);
	for tile_card in CardSelector.instance.cards_selected:
		var tween = get_tree().create_tween();
		tween.tween_callback(func(): tile_card.discard());
		tween.tween_interval(0.1);
		await tween.finished;
	CardSelector.instance.clear_multi_card_selection();
