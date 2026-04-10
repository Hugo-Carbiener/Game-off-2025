extends Control
class_name Fader

@export var initial_color : Color = Color(1., 1., 1., 0.1)

func _ready() -> void:
	modulate = Color(0.0, 0.0, 0.0, 0.0);
	AnimationUtils.fade(self, initial_color, 2.);
	mouse_entered.connect(on_mouse_enter);
	mouse_exited.connect(on_mouse_exit);

func on_mouse_enter():
	if UserSettings.are_input_blocked: return;
	
	AnimationUtils.fade(self, Color(1.0, 1.0, 1.0, 1.0), 0.5);

func on_mouse_exit():
	AnimationUtils.fade(self, initial_color, 0.25);
