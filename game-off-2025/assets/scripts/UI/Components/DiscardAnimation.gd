class_name DiscardAnimation extends Sprite2D

const discard_animation_scene = preload("res://scenes/components/DiscardAnimation.tscn");

@export var particle_system : CPUParticles2D;
@export var trajectory_variance : float;
@export var trajectory_amplitude : float;
@export var discard_animation_duration : float;

static func launch_discard_animation(tile_card : TileCard, from : Vector2, to : Vector2, root : CanvasItem):
	var discard_animation = discard_animation_scene.instantiate();
	discard_animation.setup(tile_card);
	root.add_child(discard_animation);
	await discard_animation.start_lifetime(from, to);
	discard_animation.queue_free();

func setup(tile_card : TileCard):
	particle_system.restart();
	var tile_data = TileDataManager.tile_dictionnary[tile_card.card_id];
	if tile_data == null: return;
	
	texture.region = tile_data.get_texture_region();
	visible = true;

func start_lifetime(from : Vector2, to : Vector2):
	var curve = Curve2D.new();
	var direction = to - from;
	var normal = Vector2(direction.y, -direction.x).normalized();
	var curvature_strength = randf_range(1.0, trajectory_variance);
	var control_offset = normal * curvature_strength * trajectory_amplitude;
	curve.add_point(from, Vector2.ZERO, control_offset)
	curve.add_point(to, -control_offset / 2.0, Vector2.ZERO)
	var tween = get_tree().create_tween();
	tween.tween_method(
		func(t: float): 
			global_position = curve.sample(0, t),
			0.0,    # Start value
			1.0,    # End value
			discard_animation_duration
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT);
	await particle_system.finished;
	queue_free();
