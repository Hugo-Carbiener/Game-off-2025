extends Node
class_name TutorialScreen

@export var UI : Control;
@export var text : Label;
@export var press_next_key : Label;
@export var next_scene : PackedScene;
@export_group("Durations")
@export var text_reveal_duration : float;
@export var fade_out_duration : float;
var ready_to_switch = false;
var tween;

func _ready() -> void:
	text.visible_characters = 0;
	press_next_key.modulate = Color(1.0,1.0,1.0,0.0);
	await text_reveal();

func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventMouseButton) and event.is_released():
		# we wait for the text to be displayed
		if !ready_to_switch:
			# on input we display all the text
			tween.pause();
			tween.custom_step(text_reveal_duration);
			return;
	
		await fade_out();
		get_tree().change_scene_to_packed(next_scene);

func text_reveal():
	tween = get_tree().create_tween();
	tween.tween_property(text, "visible_characters", text.text.length(), text_reveal_duration);
	await tween.finished;
	ready_to_switch = true;
	press_next_key.modulate = Color(1.0,1.0,1.0,1.0);
	return;

func fade_out():
	tween = get_tree().create_tween();  
	tween.tween_property(UI, "modulate", Color(1,1,1,0), fade_out_duration);
	await tween.finished;
	return;
