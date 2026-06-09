class_name DrawPile extends TextureButton

var cards : Dictionary[String, int];
var detail_is_active : bool = false;

@export var folding_icon : TextureRect;
@export var deck_window : Control;
@export var deck_element_container_window : Control;

func _ready() -> void:
	pivot_offset = size / 2;
	SignalBus.card_drawn.connect(on_card_drawn);
	button_down.connect(on_click);
	for playable_tile in TileDataManager.playable_tiles:
		cards.set(playable_tile, 1);

func on_card_drawn(tile_card : TileCard):
	# dispatch at the end of the frame so that the Hbox layout has time to be computed
	call_deferred("dispatch_drawn_card", tile_card);

func dispatch_drawn_card(tile_card : TileCard):
	TileCardFactory.instance.update_card_count_label();
	AnimationUtils.bounce(self, 1.5);
	await ElementMovementAnimation.launch_element_movement_animation(tile_card.card_sprite.texture, global_position + size / 2, tile_card.card_sprite.global_position, self);
	AnimationUtils.animate_scale(tile_card, Vector2.ZERO, Vector2.ONE, tile_card.card_movement_transition_duration);
	await AnimationUtils.fade(tile_card, 1, tile_card.card_movement_transition_duration);
	tile_card.modulate.a = 1;

func on_click():
	detail_is_active = !detail_is_active;
	if detail_is_active:
		await open_deck();
	else:
		await close_deck();
	folding_icon.flip_v = detail_is_active;

func open_deck():
	var deck_elements : Array[DeckElement];
	for tile_id in cards.keys():
		deck_elements.append(DeckElement.create_deck_element(tile_id, get_card_probability(tile_id)));
	deck_window.modulate.a = 0;
	deck_window.visible = true;
	await AnimationUtils.fade(deck_window, 1, 0.1);
	for deck_element in deck_elements:
		if deck_element == null: continue;
		await AnimationUtils.add_child_fade_in(deck_element_container_window, deck_element, 0.1);

func get_card_probability(tile_id : String) -> float:
	return float(cards[tile_id]) / get_deck_size() * 100;

func close_deck():
	var container_children = deck_element_container_window.get_children();
	for deck_element_idx in range(container_children.size() - 1, -1, -1):
		var deck_element = container_children[deck_element_idx];
		if deck_element is not DeckElement: continue;
		
		await AnimationUtils.delete_child_fade_out(deck_element, 0.1);
	await AnimationUtils.fade(deck_window, 0, 0.1);
	deck_window.visible = false;

func get_deck_size() -> int:
	var sum = 0;
	for card_amount in cards.values():
		sum += card_amount;
	return sum;
