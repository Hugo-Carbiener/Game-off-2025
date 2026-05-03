extends Node2D

func add_child_fade_in(parent : CanvasItem, child : CanvasItem, duration : float):
	child.modulate.a = 0;
	var tween = get_tree().create_tween();
	tween.tween_callback(func(): parent.add_child(child));
	tween.tween_property(child, "modulate:a", 1., duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	await tween.finished;

func delete_child_fade_out(child : CanvasItem, duration : float):
	var tween = get_tree().create_tween();
	tween.tween_property(child, "modulate:a", 0., duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tween.tween_callback(func(): child.queue_free());
	await tween.finished;

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

func fade(target : CanvasItem, to : Color, duration : float, delay : float = 0.) -> Tween:
	var tween = get_tree().create_tween();
	tween.tween_property(target, "modulate", to, duration).set_delay(delay).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	await tween.finished;
	return tween;

func animate_scale(target : CanvasItem, from : Vector2, to : Vector2, duration : float):
	var tween = get_tree().create_tween();
	tween.tween_property(target, "scale", to, duration).from(from).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT);
	await tween.finished;
	return tween;
