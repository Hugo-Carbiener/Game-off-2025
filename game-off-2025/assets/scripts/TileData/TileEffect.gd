@tool
extends Resource
class_name TileEffect

enum EFFECT {
	GIVE_STATUS,
	DAMAGE_NEIGHBOR,
	HEAL
}

@export_group("Give status variables")
@export var status_to_give : MonsterFactory.STATUS;
@export_group("Damage neighbor variables")
@export var damage_neighbor : int;
@export_group("Heal variables")
@export var heal : int;
@export_group("Effect variables")
@export var icons_paths : Array[String];
var icons : Array[Resource];
@export var effect : EFFECT:
	set(value):
		effect = value;
		property_list_changed.emit(); ## update exported fields

## Hide useless fields
const fields_per_effect : Dictionary[StringName, EFFECT] = {
	&"status_to_give" : EFFECT.GIVE_STATUS,
	&"damage_neighbor" : EFFECT.DAMAGE_NEIGHBOR,
	&"heal" : EFFECT.HEAL
}
const field_groups_per_effect : Dictionary[StringName, EFFECT] = {
	&"Give status variables" : EFFECT.GIVE_STATUS,
	&"Damage neighbor variables" : EFFECT.DAMAGE_NEIGHBOR,
	&"Heal variables" : EFFECT.HEAL
}

func _validate_property(property : Dictionary) -> void:
	if fields_per_effect[property.name] == effect:
		property.usage |= PROPERTY_USAGE_EDITOR
	else:
		property.usage &= ~PROPERTY_USAGE_EDITOR
	
	if field_groups_per_effect[property.name] == effect :
		property.usage |= PROPERTY_USAGE_GROUP
	else:
		property.usage &= ~PROPERTY_USAGE_GROUP

func execute(monster : Monster):
	var value;
	match effect:
		EFFECT.GIVE_STATUS:
			monster.set_status(status_to_give);
		
		EFFECT.DAMAGE_NEIGHBOR:
			value = damage_neighbor;
			monster.damage(damage_neighbor);
		
		EFFECT.HEAL:
			value = heal;
			BeaconManager.instance.damage(-1 * heal);
	
	if value != 0 and !icons_paths.is_empty():
		
		monster.dispatch_interaction(str(value), get_icons());

func get_icons() -> Array[Resource]:
	if icons == null or icons.is_empty():
			for icon_path in icons_paths:
				icons.append(load(icon_path));
	return icons;
