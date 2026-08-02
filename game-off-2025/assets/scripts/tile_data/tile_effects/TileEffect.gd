@tool
extends Resource
class_name TileEffect

@export var value : int;
@export var tile_value : String;
@export_group("Trigger")
@export var trigger : TileDataManager.TRIGGERS;
@export_group("Effect variables")
@export var title : String;
@export var icon : Texture2D;
@export var effect : EFFECT:
	set(value):
		effect = value;
		property_list_changed.emit(); ## update exported fields

enum EFFECT {
	CHANNELED,
	DRAINED,
	INCREASE_TILE_DAMAGE,
	INCREASE_RANGED_TILE_DAMAGE,
	DEAL_DAMAGE,
	GROW_BIOME,
	MONSTER_WEAKNESS,
	MONSTER_DAMAGE_REDUCTION,
	BEACON_HEAL,
	BEACON_SHIELD,
	PLACE_TILE,
	DESTROY_TILE,
	FILL_WITH_TILE,
	INCREASE_MAX_RANGE,
	SPAWN_MONSTER,
	GAIN_INSTABILITY
}

var effect_actions : Dictionary[EFFECT, EffectAction] = {
	EFFECT.CHANNELED : ChanneledEffectAction.new(self),
	EFFECT.DRAINED : DrainedEffectAction.new(self),
	EFFECT.INCREASE_TILE_DAMAGE : IncreaseTileDamageEffectAction.new(self),
	EFFECT.INCREASE_RANGED_TILE_DAMAGE : IncreaseRangedTileDamageEffectAction.new(self),
	EFFECT.DEAL_DAMAGE : DealDamageEffectAction.new(self),
	EFFECT.GROW_BIOME : GrowBiomeEffectAction.new(self),
	EFFECT.MONSTER_WEAKNESS : MonsterWeaknessEffectAction.new(self),
	EFFECT.MONSTER_DAMAGE_REDUCTION : MonsterDamageReductionEffectAction.new(self),
	EFFECT.BEACON_HEAL : BeaconHealEffectAction.new(self),
	EFFECT.BEACON_SHIELD : BeaconShieldEffectAction.new(self),
	EFFECT.PLACE_TILE : PlaceTileEffectAction.new(self),
	EFFECT.FILL_WITH_TILE : FillWithTileEffectAction.new(self),
	EFFECT.INCREASE_MAX_RANGE : IncreaseMaxRangeEffectAction.new(self),
	EFFECT.SPAWN_MONSTER : SpawnMonsterEffectAction.new(self),
	EFFECT.GAIN_INSTABILITY : GainInstabilityEffectAction.new(self),
}

## Descriptions
var trigger_descriptions : Dictionary[TileDataManager.TRIGGERS, String] = {
	TileDataManager.TRIGGERS.NONE : "",
	TileDataManager.TRIGGERS.ON_MONSTER_WALK : "When an enemy enters",
	TileDataManager.TRIGGERS.ON_SETUP_START : "At the start of the breaches' turn",
	TileDataManager.TRIGGERS.ON_RESOLUTION_START : "At the start of the monsters' turn",
	TileDataManager.TRIGGERS.ON_RESOLUTION_END : "At the end of the monsters' turn",
	TileDataManager.TRIGGERS.ON_MONSTER_DEATH : "When a monster dies in range",
	TileDataManager.TRIGGERS.ON_TILE_PLACED : "When a land tile is placed in range",
	TileDataManager.TRIGGERS.ON_BEACON_DAMAGE : "When the beacon is damaged",
}

var wildcards : Dictionary[String, String] = {
	"{value}" : str(value),
	"{tile_value}" : tile_value,
}

## Hide useless fields
const values_always_displayed : Array[StringName] = [&"trigger", &"title", &"description", &"icon", &"effect"];
const value_per_effect : Dictionary[EFFECT, StringName] = {
	EFFECT.CHANNELED : &"",
	EFFECT.DRAINED : &"",
	EFFECT.INCREASE_TILE_DAMAGE : &"value",
	EFFECT.INCREASE_RANGED_TILE_DAMAGE : &"value",
	EFFECT.DEAL_DAMAGE : &"value",
	EFFECT.GROW_BIOME : &"tile_value",
	EFFECT.MONSTER_WEAKNESS : &"value",
	EFFECT.MONSTER_DAMAGE_REDUCTION : &"value",
	EFFECT.BEACON_HEAL : &"value",
	EFFECT.BEACON_SHIELD : &"value",
	EFFECT.PLACE_TILE : &"tile_value",
	EFFECT.DESTROY_TILE : &"tile_value",
	EFFECT.FILL_WITH_TILE : &"tile_value",
	EFFECT.INCREASE_MAX_RANGE : &"value",
	EFFECT.SPAWN_MONSTER : &"value",
	EFFECT.GAIN_INSTABILITY : &"value",
}

func _validate_property(property : Dictionary) -> void:
	if value_per_effect[effect] == property.name or values_always_displayed.has(property.name):
		property.usage |= PROPERTY_USAGE_EDITOR
	else:
		property.usage &= ~PROPERTY_USAGE_EDITOR

func execute(_trigger : TileDataManager.TRIGGERS, tile_position : Vector2i, tile_data : CustomTileData):
	if trigger != _trigger or _trigger == TileDataManager.TRIGGERS.NONE: return;
	
	if !effect_actions.has(effect):
		printerr("Effect " + str(effect) + " has no action.");
		return;
	
	effect_actions[effect].execute(tile_position, tile_data);

func get_value() -> int:
	return value;

func get_tile_value() -> String:
	return tile_value;

func get_value_to_string() -> String:
	if value != 0:
		return str(value);
	
	if tile_value != null && tile_value != "":
		return tile_value;
	
	printerr("No valid value on effect " + resource_name + " at " + resource_path);
	return "";

func get_description() -> String:
	var trigger_description = trigger_descriptions[trigger];
	var effect_description = effect_actions[effect].get_description();
	return trigger_description + (", " if !trigger_description.is_empty() else "") + effect_description.format(wildcards);
