class_name MonsterHealthIndicator extends Control

@export var monster_health : MonsterTextDamage;
@export var monster_damage_container : VBoxContainer;

func setup(monster : Monster):
	monster_health.setup(str(monster.health), TileDataManager.heal_icon_small);
	for monster_damage in monster_damage_container.get_children():
		monster_damage.queue_free();

func on_damage(monster : Monster, damage_amount : int, is_ranged: bool):
	await instantiate_damage_element(damage_amount, is_ranged);
	AnimationUtils.animate_integer(update_health_label, monster.health, max(0, monster.health - damage_amount));

func update_health_label(damage_amount : int):
	monster_health.label.text = str(round(damage_amount));

func instantiate_damage_element(damage_amount : int, is_ranged: bool):
	var icon = TileDataManager.damage_icon_small if not is_ranged else TileDataManager.ranged_damage_icon_small;
	var monster_damage = MonsterTextDamage.create_monster_text_damage("-" + str(damage_amount), icon);
	monster_damage_container.add_child(monster_damage);
	await monster_damage.start_lifetime();
