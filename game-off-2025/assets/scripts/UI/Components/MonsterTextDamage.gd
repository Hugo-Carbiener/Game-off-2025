extends Control
class_name MonsterTextDamage

const monster_text_damage_scene = preload("res://scenes/components/MonsterTextDamage.tscn");

@export var label : Label;
@export var icon : TextureRect;

static func create_monster_text_damage(text : String, texture: Texture2D, color : Color = Color.WHITE) -> MonsterTextDamage:
	var monster_text_damage = monster_text_damage_scene.instantiate();
	monster_text_damage.setup(text, texture, color);
	return monster_text_damage;

func setup(text : String, texture : Texture2D, color : Color = Color.WHITE):
	label.text = text;
	icon.texture = texture;
	modulate = color;

func start_lifetime():
	await AnimationUtils.fade(self, Color.TRANSPARENT, Constants.monster_info_lifetime_duration / 2., Constants.monster_info_lifetime_duration / 2.);
	queue_free();
