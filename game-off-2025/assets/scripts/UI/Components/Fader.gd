class_name Fader extends Control

func _ready() -> void:
	AnimationUtils.fade(self, 0.2, 2.);
	mouse_entered.connect(on_mouse_enter);
	mouse_exited.connect(on_mouse_exit);

func on_mouse_enter():
	if UserSettings.are_input_blocked: return;
	
	AnimationUtils.fade(self, 1, 0.25);

func on_mouse_exit():
	AnimationUtils.fade(self, 0.2, 0.25);
