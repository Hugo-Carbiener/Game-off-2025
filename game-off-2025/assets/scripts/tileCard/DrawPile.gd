class_name DrawPile extends CardPile

static var instance : DrawPile;

var detail_is_active : bool = false;

@export var button : TextureButton;
@export var folding_icon : TextureRect;
@export var deck_window : Control;
@export var deck_element_container_window : Control;

func _ready() -> void:
	if instance == null:
		instance = self;
	pivot_offset = size / 2;
	SignalBus.card_drawn.connect(on_card_drawn);
	button.button_down.connect(on_click);
	populate_draw();

func populate_draw():
	for card_in_deck in UserData.card_deck:
		cards.append(card_in_deck);
	update_card_amount();

func draw_random_card():
	if get_pile_size() == 0:
		await refill_draw();
	
	if get_pile_size() == 0:
		printerr("Attempted to draw on empty draw pile");
		return;
		
	var index = randi() % cards.size();
	draw_card(cards[index]);

func draw_card(card_id : String):
	var tile_card = TileCard.create_tile_card(card_id);
	remove_card(tile_card);
	HandPile.instance.add_card(tile_card);
	on_card_drawn(tile_card);

func draw_hand():
	var tween = get_tree().create_tween();
	tween.set_loops(Constants.base_card_per_round);
	tween.tween_callback(draw_random_card);
	tween.tween_interval(Constants.card_draw_interval);
	await tween.finished;

func on_card_drawn(tile_card : TileCard):
	# dispatch at the end of the frame so that the Hbox layout has time to be computed
	call_deferred("dispatch_drawn_card", tile_card);

func dispatch_drawn_card(tile_card : TileCard):
	AnimationUtils.bounce(self, 1.5);
	await ElementMovementAnimation.launch_element_movement_animation(tile_card.card_sprite.texture.region, global_position + size / 2, tile_card.card_sprite.global_position, self);
	AnimationUtils.animate_scale(tile_card, Vector2.ZERO, Vector2.ONE, tile_card.card_movement_transition_duration);
	await AnimationUtils.fade(tile_card, 1, tile_card.card_movement_transition_duration);
	tile_card.modulate.a = 1;

func refill_draw():
	DiscardPile.instance.cards.shuffle();
	for i in range(DiscardPile.instance.get_pile_size() - 1, -1, -1):
		var card_to_move = DiscardPile.instance.cards[i];
		cards.append(card_to_move);
		DiscardPile.instance.cards.pop_at(i);
		DiscardPile.instance.update_card_amount();
		await dispatch_refill(card_to_move);
		update_card_amount();

func dispatch_refill(card_id : String):
	var card_sprite_region = TileDataManager.tile_dictionnary[card_id].get_texture_region();
	ElementMovementAnimation.launch_element_movement_animation(card_sprite_region, DiscardPile.instance.global_position + (size / 2), global_position + (size / 2), self);
	AnimationUtils.bounce(self, 1.5);
	var tween = get_tree().create_tween();
	tween.tween_interval(Constants.card_draw_interval);
	await tween.finished;

func on_click():
	detail_is_active = !detail_is_active;
	if detail_is_active:
		await open_deck();
	else:
		await close_deck();
	folding_icon.flip_v = detail_is_active;

func open_deck():
	var deck_elements : Array[DeckElement];
	for tile_id in cards:
		deck_elements.append(DeckElement.create_deck_element(tile_id, get_card_probability(tile_id)));
	deck_window.modulate.a = 0;
	deck_window.visible = true;
	await AnimationUtils.fade(deck_window, 1, 0.1);
	for deck_element in deck_elements:
		if deck_element == null: continue;
		await AnimationUtils.add_child_fade_in(deck_element_container_window, deck_element, 0.1);

func get_card_probability(tile_id : String) -> float:
	var amount = 0;
	for card in cards:
		if card == tile_id:
			amount += 1;
	return float(amount) / cards.size() * 100;

func close_deck():
	var container_children = deck_element_container_window.get_children();
	for deck_element_idx in range(container_children.size() - 1, -1, -1):
		var deck_element = container_children[deck_element_idx];
		if deck_element is not DeckElement: continue;
		
		await AnimationUtils.delete_child_fade_out(deck_element, 0.1);
	await AnimationUtils.fade(deck_window, 0, 0.1);
	deck_window.visible = false;
