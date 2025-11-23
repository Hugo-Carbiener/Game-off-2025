extends Control
class_name MonsterInfo

@export var label : Label;
@export var icon_model : TextureRect;
var starting_position : Vector2;

func launch(_position : Vector2, text : String, icons : Array[ImageTexture]):
	position = _position
	starting_position = _position;
	init(text, icons);
	await start_lifetime();
	if visible:
		print("stayed visible")

func init(text : String, icons : Array[ImageTexture]):
	visible = true;
	icon_model.visible = true;
	modulate = Color(0, 0, 0, 1.0);
	label.text = text;
	
	for child in get_children():
		if child == label or child == icon_model: continue;
		child.queue_free();
	
	for icon in icons:
		var icon_container = icon_model.duplicate();
		icon_container.texture = icon;
		add_child(icon_container);
	icon_model.visible = false;

func start_lifetime():
	var tween = get_tree().create_tween();
	tween.set_parallel(true);
	tween.tween_property(self, "modulate", Color(0, 0, 0, 0), Constants.monster_info_lifetime_duration).set_ease(Tween.EASE_IN);
	tween.tween_property(self, "position", starting_position + Constants.monster_info_lifetime_movement, Constants.monster_info_lifetime_duration).set_ease(Tween.EASE_OUT);
	tween.set_parallel(false);
	tween.tween_callback(func(): visible = false);
	await tween.finished;
