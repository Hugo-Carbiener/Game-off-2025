class_name MonsterTextDamage extends Control

const monster_text_damage_scene = preload("res://scenes/components/MonsterTextDamage.tscn");

@export var label : Label;
@export var icon : TextureRect;

static func create_monster_text_damage(text : String, texture: Texture2D, color : Color = Color.WHITE) -> MonsterTextDamage:
	var monster_text_damage = monster_text_damage_scene.instantiate();
	monster_text_damage.setup(text, texture, color);
	return monster_text_damage;

static func create_animated_monster_text_damage(text : String, texture: Texture2D, is_in_open_world : bool, color : Color = Color.WHITE) -> MonsterTextDamage:
	var monster_text_damage = monster_text_damage_scene.instantiate();
	monster_text_damage.setup(text, texture, color);
	monster_text_damage.start_lifetime(is_in_open_world);
	return monster_text_damage;

func setup(text : String, texture : Texture2D, color : Color = Color.WHITE):
	label.text = text;
	icon.texture = texture;
	modulate = color;

func start_lifetime(is_in_open_world : bool = false):
	if is_in_open_world:
		AnimationUtils.push(self, Constants.default_ui_fade_offset, Constants.monster_info_lifetime_duration * 2);
	await AnimationUtils.fade(self, 0, Constants.monster_info_lifetime_duration / 2., Constants.monster_info_lifetime_duration / 2.);
	queue_free();
