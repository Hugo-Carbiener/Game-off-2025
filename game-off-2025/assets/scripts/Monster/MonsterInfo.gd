extends Control
class_name MonsterInfo

const monster_info_scene = preload("res://scenes/components/MonsterInfo.tscn");

@export var label : Label;
@export var icon : TextureRect;

static func launch_monster_info(text : String, texture: Texture2D, starting_position : Vector2, root : Node2D, color : Color = Color.WHITE):
	var monster_info = monster_info_scene.instantiate();
	monster_info.setup(text, texture, color);
	root.add_child(monster_info);
	await monster_info.start_lifetime(starting_position);
	monster_info.queue_free();

func setup(text : String, texture : Texture2D, color : Color = Color.WHITE):
	label.text = text;
	icon.texture = texture;
	modulate = color;

func start_lifetime(starting_position : Vector2):
	position = starting_position;
	var tween = get_tree().create_tween();
	tween.set_parallel(true);
	tween.tween_property(self, "position", position + Constants.monster_info_lifetime_movement, Constants.monster_info_lifetime_duration).set_ease(Tween.EASE_OUT);
	tween.tween_property(self, "modulate:a", 0, Constants.monster_info_lifetime_duration / 2.).set_delay(Constants.monster_info_lifetime_duration / 2.).set_ease(Tween.EASE_OUT);
	await tween.finished;
	return;
