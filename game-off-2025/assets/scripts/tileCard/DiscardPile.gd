class_name DiscardPile extends CardPile

static var instance : DiscardPile;

@export var discard_window : DiscardWindow;

func _ready() -> void:
	if instance == null:
		instance = self;
	pivot_offset = size / 2;
	SignalBus.play_phase_started.connect(on_play_phase_start);
	update_card_amount();

func discard_from_card(tile_card : TileCard):
	add_card(tile_card);
	tile_card.on_discarded();
	await ElementMovementAnimation.launch_element_movement_animation(tile_card.card_sprite.texture.region, tile_card.card_sprite.global_position, global_position + size / 2, self);
	AnimationUtils.bounce(self, 1.5);
	update_card_amount();

#func discard_from_tile(tile_position : Vector2i):
	#var car_sprite_region = TileDataManager.tile_dictionnary[card_id].get_texture_region();
	#await ElementMovementAnimation.launch_element_movement_animation(car_sprite_region, tile_card.card_sprite.global_position, global_position + size / 2, self);
	#AnimationUtils.bounce(self, 1.5);
	#cards.append(card_id);
	#update_card_amount();

func on_play_phase_start():
	var card_to_discard_amount = HandPile.instance.get_pile_size() - Constants.base_card_hand_size;
	if card_to_discard_amount > 0:
		discard_window.setup(card_to_discard_amount, HandPile.instance.tile_cards);
