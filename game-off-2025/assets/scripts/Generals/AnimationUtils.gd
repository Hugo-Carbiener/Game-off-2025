extends Node2D

func blink_sprite(target : CanvasItem, duration : float) -> Tween:
	var base_color = target.modulate;
	var tween = get_tree().create_tween();
	tween.tween_property(target, "modulate", Color(10, 10, 10, 1), duration/2).from(base_color);
	tween.tween_property(target, "modulate", base_color
	, duration/2).from(Color(10, 10, 10, 1));
	await tween.finished;
	return tween;

func fade(target : CanvasItem, to : Color, duration : float) -> Tween:
	var tween = get_tree().create_tween();
	tween.tween_property(target, "modulate", to, duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	await tween.finished;
	return tween;
