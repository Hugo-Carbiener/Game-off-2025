@tool
extends Resource
class_name TileEffect

enum EFFECT {
	GIVE_STATUS,
	DAMAGE_NEIGHBOR
}

@export_group("Give status variables")
@export var status_to_give : MonsterFactory.STATUS;
@export_group("Damage neighbor variables")
@export var damage : int;
@export_group("Effect variables")
@export var effect : EFFECT:
	set(value):
		effect = value;
		property_list_changed.emit(); ## update exported fields

## Hide useless fields
const fields_per_effect : Dictionary[StringName, EFFECT] = {
	&"status_to_give" : EFFECT.GIVE_STATUS,
	&"damage" : EFFECT.DAMAGE_NEIGHBOR
}
const field_groups_per_effect : Dictionary[StringName, EFFECT] = {
	&"Give status variables" : EFFECT.GIVE_STATUS,
	&"Damage neighbor variables" : EFFECT.DAMAGE_NEIGHBOR
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
	match effect:
		EFFECT.GIVE_STATUS:
			monster.give_status(status_to_give);
			return;
		
		EFFECT.DAMAGE_NEIGHBOR:
			print("dealt damage on neighbor monster on " + str(monster.tilemap_position));
			monster.damage(damage);
			return;
