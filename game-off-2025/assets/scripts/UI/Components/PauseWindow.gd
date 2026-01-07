extends Control
class_name PauseWindow

@export_group("Buttons")
@export var close_button : TextureButton;
@export var main_menu_button : TextureButton;
@export var quit_button : TextureButton;

func _ready() -> void:
	close_button.button_up.connect(close);
	main_menu_button.button_up.connect(UIUtils.main_menu);
	quit_button.button_up.connect(UIUtils.quit_game);

func close():
	visible = false
