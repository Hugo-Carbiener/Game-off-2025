class_name TileAnimationPlayer extends AnimatedSprite2D

const TILE_APPARITION_ANIMATION_KEY = "tile-apparition";

func on_tile_apparition(_position : Vector2):
	position = _position;
	visible = true;
	play(TILE_APPARITION_ANIMATION_KEY);
	await animation_finished;
	visible = false;
