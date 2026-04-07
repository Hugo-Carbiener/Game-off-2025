class_name DiscardPile extends Control

var cards : Array[String];

func _ready() -> void:
	pivot_offset = size / 2;
	SignalBus.card_discarded.connect(discard);

func discard(tile_card : TileCard):
	cards.append(tile_card.card_id);
	await DiscardAnimation.launch_discard_animation(tile_card, tile_card.card_sprite.global_position, global_position + size / 2, self);
	AnimationUtils.bounce(self, 1.5);
