extends Camera2D

func get_camera() -> Camera2D:
	return self;

func zoom_transition(center : Vector2, target_zoom : Vector2):
	var tween = get_tree().create_tween();
	tween.set_parallel(true);
	tween.tween_property(self, "position", center, Constants.camera_transition_duration);
	tween.tween_property(self, "zoom", target_zoom, Constants.camera_transition_duration);
	await tween.finished;
