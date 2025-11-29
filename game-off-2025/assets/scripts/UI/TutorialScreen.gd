extends Node
class_name TutorialScreen

@export var UI : Control;
@export var text : Label;
@export var next_scene : PackedScene;
@export_group("Durations")
@export var text_reveal_duration : float;
@export var fade_out_duration : float;

func _ready() -> void:
	text.visible_characters = 0;
	await text_reveal();

func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
		await fade_out();
		get_tree().change_scene_to_packed(next_scene);

func text_reveal():
	var tween = get_tree().create_tween();
	tween.tween_property(text, "visible_characters", text.text.length(), text_reveal_duration);
	await tween.finished;
	return;

func fade_out():
	var tween = get_tree().create_tween();
	tween.tween_property(UI, "modulate", Color(1,1,1,0), fade_out_duration);
	await tween.finished;
	return;
