extends Control
class_name PauseWindow

@export var close_button : TextureButton;

func _ready() -> void:
	close_button.button_up.connect(close);

func close():
	visible = false
