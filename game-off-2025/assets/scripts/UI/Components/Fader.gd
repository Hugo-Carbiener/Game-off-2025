class_name Fader extends Control

@export var initial_color : Color = Color(1., 1., 1., 0.1)

func _ready() -> void:
	modulate = Color(0.0, 0.0, 0.0, 0.0);
	AnimationUtils.fade(self, initial_color.a, 2.);
	mouse_entered.connect(on_mouse_enter);
	mouse_exited.connect(on_mouse_exit);

func on_mouse_enter():
	if UserSettings.are_input_blocked: return;
	
	AnimationUtils.fade(self, 1, 0.25);

func on_mouse_exit():
	AnimationUtils.fade(self, initial_color.a, 0.25);
