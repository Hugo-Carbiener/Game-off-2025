class_name Notification extends Control

const notification_scene : PackedScene = preload("res://scenes/components/Notification.tscn");

@export_group("Components")
@export var icon : TextureRect;
@export var label : Label;
@export var button : TextureButton;
@export_group("Durations")
@export var life_duration : float;
@export var hover_transition_duration : float;
@export var init_transition_duration : float;
@export var end_of_life_duration : float;
@export_group("Margins")
@export var hover_margin : int;
@export var end_of_life_margin : int;

var base_right_margin : int;
var is_disappearing = false;

func _ready() -> void:
	on_init();
	base_right_margin = get_theme_constant("margin_right");
	init_timer();
	mouse_entered.connect(on_mouse_enter);
	mouse_exited.connect(on_mouse_exit);

func init_timer():
	var timer = Timer.new();
	add_child(timer);
	timer.start(life_duration);
	timer.timeout.connect(end_notification);

static func create_notification() -> Notification:
	return notification_scene.instantiate();

func with_icon(_icon : Texture2D) -> Notification:
	icon.texture = _icon;
	return self;

func with_atlas_icon(tile_data : CustomTileData) -> Notification:
	icon.texture = icon.texture.duplicate();
	icon.texture.region = tile_data.get_texture_region();
	return self;

func with_text(text : String) -> Notification:
	label.text = text;
	return self;

func with_button(callable : Callable) -> Notification:
	button.button_up.connect(callable);
	button.button_up.connect(end_notification);
	return self;

func on_mouse_enter():
	if is_disappearing: return;
	
	var tween = get_tree().create_tween();
	tween.tween_method(update_right_margin, get_theme_constant("margin_right"), base_right_margin + hover_margin, hover_transition_duration).set_ease(Tween.EASE_OUT);

func on_mouse_exit():
	if is_disappearing: return;
	
	var tween = get_tree().create_tween();
	tween.tween_method(update_right_margin, get_theme_constant("margin_right"), base_right_margin, hover_transition_duration).set_ease(Tween.EASE_OUT);

func on_init():
	modulate = Color(0.0, 0.0, 0.0, 0.0);
	var tween = get_tree().create_tween();
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), end_of_life_duration);

func update_right_margin(margin : int):
	add_theme_constant_override("margin_right", margin);

func end_notification():
	is_disappearing = true;
	var tween = get_tree().create_tween();
	tween.set_parallel(true);
	tween.tween_property(self, "position", position + Vector2.UP * end_of_life_margin, end_of_life_duration);
	tween.tween_property(self, "modulate", Color(0.0, 0.0, 0.0, 0.0), end_of_life_duration);
	await tween.finished;
	queue_free();
