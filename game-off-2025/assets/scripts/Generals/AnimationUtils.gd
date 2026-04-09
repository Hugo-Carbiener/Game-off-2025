extends Node2D

func blink_sprite(target : CanvasItem, color : Color = Color.WHITE) -> Tween:
	var base_color = target.modulate;
	var blink_color = Color(10, 10, 10, 1) * color;
	var tween = get_tree().create_tween();
	tween.tween_property(target, "modulate", blink_color, Constants.blink_duration/2);
	tween.tween_property(target, "modulate", base_color, Constants.blink_duration/2);
	await tween.finished;
	return tween;

func bounce(target : CanvasItem, factor : float):
	var tween = get_tree().create_tween();
	tween.tween_property(target, "scale", factor * Vector2.ONE, Constants.blink_duration);
	tween.tween_property(target, "scale", Vector2.ONE, Constants.blink_duration);
	await tween.finished;

func fade(target : CanvasItem, to : Color, duration : float) -> Tween:
	var tween = get_tree().create_tween();
	tween.tween_property(target, "modulate", to, duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	await tween.finished;
	return tween;

func animate_scale(target : CanvasItem, from : Vector2, to : Vector2, duration : float):
	var tween = get_tree().create_tween();
	tween.tween_property(target, "scale", to, duration).from(from).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN);
	await tween.finished;
	return tween;
