class_name DiscardPile extends TextureButton

var cards : Array[String];

@export var discard_pile_size_label : Label;
@export var discard_window : DiscardWindow;

func _ready() -> void:
	pivot_offset = size / 2;
	SignalBus.card_discarded.connect(discard);
	SignalBus.play_phase_started.connect(on_play_phase_start);
	update_card_amount();

func discard(tile_card : TileCard):
	cards.append(tile_card.card_id);
	await CardMovementAnimation.launch_card_movement_animation(tile_card, tile_card.card_sprite.global_position, global_position + size / 2, self);
	AnimationUtils.bounce(self, 1.5);
	update_card_amount();

func update_card_amount():
	discard_pile_size_label.text = str(cards.size());

func on_play_phase_start():
	var card_to_discard_amount = TileCardFactory.instance.get_hand_size() - Constants.base_card_hand_size;
	if card_to_discard_amount > 0:
		discard_window.setup(card_to_discard_amount, TileCardFactory.instance.cards);
