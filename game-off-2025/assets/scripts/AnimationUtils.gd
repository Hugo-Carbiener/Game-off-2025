extends Node2D

func blink_sprite(target : CanvasItem, duration : float) -> Tween:
	var base_color = target.modulate;
	var tween = get_tree().create_tween();
	tween.tween_property(target, "modulate", Color(10, 10, 10, 1), duration/2).from(base_color);
	tween.tween_property(target, "modulate", base_color
	, duration/2).from(Color(10, 10, 10, 1));
	await tween.finished;
	return tween;
