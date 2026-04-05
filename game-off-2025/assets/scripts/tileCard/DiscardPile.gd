class_name DiscardPile extends Node2D

var cards : Array[String];

func _ready() -> void:
	SignalBus.card_discarded.connect(discard);

func discard(tile_card : TileCard):
	cards.append(tile_card.card_id);
	await DiscardAnimation.launch_discard_animation(tile_card, tile_card.card_sprite.global_position, global_position, self);
	AnimationUtils.bounce(self, 1.5);
