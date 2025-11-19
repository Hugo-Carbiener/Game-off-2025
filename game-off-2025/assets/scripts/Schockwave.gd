extends TextureRect
class_name ShockWave

static var instance : ShockWave;
@export_group("Shockwave durations")
@export var small_shockwave_duration : float;
@export var large_shockwave_duration : float;

func _ready() -> void:
	if instance == null:
		instance = self;

func execute_small_shockwave(epicenter : Vector2):
	var uv_epicenter = epicenter / get_rect().size;
	var duration = init_small_shockwave(uv_epicenter);
	var tween = get_tree().create_tween();
	tween.tween_method(update_shockwave, 0.0, 1.0, duration);
	tween.tween_callback(func(): visible = false);
	await tween.finished;

func execute_large_shockwave(epicenter : Vector2):
	var uv_epicenter = epicenter / get_rect().size;
	var duration = init_large_shockwave(uv_epicenter);
	var tween = get_tree().create_tween();
	tween.tween_method(update_shockwave, 0.0, 1.0, duration);
	tween.tween_callback(func(): visible = false);
	await tween.finished;

func init_small_shockwave(epicenter : Vector2) -> float:
	material.set("shader_parameter/radius", 0);
	material.set("shader_parameter/fall_off_treshold", 0.5);
	material.set("shader_parameter/light_opacity", 0.01);
	material.set("shader_parameter/width", 0.01);
	material.set("shader_parameter/feather", 0.05);
	material.set("shader_parameter/center", epicenter);
	visible = true;
	return small_shockwave_duration;

func init_large_shockwave(epicenter : Vector2) -> float:
	material.set("shader_parameter/radius", 0);
	material.set("shader_parameter/fall_off_treshold", 100);
	material.set("shader_parameter/light_opacity", 0.01);
	material.set("shader_parameter/width", 0.004);
	material.set("shader_parameter/feather", 0.135);
	material.set("shader_parameter/center", epicenter);
	visible = true;
	return large_shockwave_duration;

func update_shockwave(radius : float):
	material.set("shader_parameter/radius", radius);
