extends Control
class_name DeathScreen

@export var main_menu_button : TextureButton;

func _ready() -> void:
	main_menu_button.button_up.connect(UIUtils.main_menu)
