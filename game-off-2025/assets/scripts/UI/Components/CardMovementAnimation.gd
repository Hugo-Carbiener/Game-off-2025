class_name ElementMovementAnimation extends Sprite2D

const element_movement_animation_scene = preload("res://scenes/components/ElementMovementAnimation.tscn");

@export var particle_system : CPUParticles2D;
@export var trajectory_variance : float;
@export var trajectory_amplitude : float;
@export var movement_animation_duration : float;
@export var fade_out_duration : float;

static func launch_element_movement_animation(sprite : Texture2D, from : Vector2, to : Vector2, root : CanvasItem):
	var movement_animation = element_movement_animation_scene.instantiate();
	movement_animation.setup(sprite);
	root.add_child(movement_animation);
	await movement_animation.start_lifetime(from, to);
	movement_animation.queue_free();

func setup(sprite : Texture2D):
	texture = sprite;

func start_lifetime(from : Vector2, to : Vector2):
	var curve = create_curve(from, to);
	var tween = get_tree().create_tween();
	tween.tween_callback(func(): particle_system.restart());
	tween.tween_callback(func(): visible = true);
	tween.set_parallel(true);
	tween.tween_method(
		func(t: float): 
			global_position = curve.sample(0, t),
			0.0,    # Start value
			1.0,    # End value
			movement_animation_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN);
	tween.tween_property(self, "self_modulate:a", 0, fade_out_duration).set_delay(movement_animation_duration - fade_out_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN);
	await particle_system.finished;
	queue_free();

func create_curve(from : Vector2, to : Vector2) -> Curve2D:
	var curve = Curve2D.new();
	var direction = to - from;
	var normal = Vector2(direction.y, -direction.x).normalized();
	var curvature_strength = randf_range(1.0, trajectory_variance);
	var control_offset = normal * curvature_strength * trajectory_amplitude;
	curve.add_point(from, Vector2.ZERO, control_offset);
	curve.add_point(to, -control_offset / 2.0, Vector2.ZERO);
	return curve;
