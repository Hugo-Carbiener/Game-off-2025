extends TextureButton
class_name ToggleButton

@export var pressed_hovered_texture : Texture2D;
var base_pressed_texture : Texture2D;

func _ready() -> void:
	base_pressed_texture = texture_pressed;
	mouse_entered.connect(on_mouse_entered);
	mouse_exited.connect(on_mouse_exit);

func on_mouse_entered():
	if button_pressed:
		texture_pressed = pressed_hovered_texture;

func on_mouse_exit():
	if button_pressed:
		texture_pressed = base_pressed_texture;
