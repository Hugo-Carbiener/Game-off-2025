class_name DrawPile extends TextureButton

var cards : Array[String];

func _ready() -> void:
	pivot_offset = size / 2;
	SignalBus.card_drawn.connect(draw);

func draw(tile_card : TileCard):
	AnimationUtils.bounce(self, 1.5);
	tile_card.visible = false;
	TileCardFactory.instance.add_child(tile_card);
	await CardMovementAnimation.launch_card_movement_animation(tile_card, global_position + size / 2, tile_card.global_position, self);
	tile_card.visible = true;
	TileCardFactory.instance.update_card_count_label();
