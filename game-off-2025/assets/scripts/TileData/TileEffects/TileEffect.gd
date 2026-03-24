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
	INCREASE_TILE_DAMAGE,
	INCREASE_RANGED_TILE_DAMAGE,
	MULTIPLY_TILE_DAMAGE,
	DEAL_DAMAGE,
	POISON,
	ROOT,
	GROW_BIOME,
	GAIN_TEMPORARY_VOID_CHARGES,
	MONSTER_WEAKNESS,
	MONSTER_DAMAGE_REDUCTION,
	FIRE,
	EVOLVE,
	DEVOLVE,
	BEACON_HEAL,
	BEACON_SHIELD,
	TRIGGER_RANDOM_TILE,
	TRIGGER_ALL_TILES,
	PLACE_TILE,
	REMOVE_TILE,
	FILL_WITH_TILE,
	FILL_WITH_TILE_OR_EVOLVE,
	INCREASE_MAX_RANGE,
}

var effect_actions : Dictionary[EFFECT, EffectAction] = {
	EFFECT.INCREASE_TILE_DAMAGE : IncreaseTileDamageEffectAction.new(self),
	EFFECT.INCREASE_RANGED_TILE_DAMAGE : IncreaseRangedTileDamageEffectAction.new(self),
	EFFECT.MULTIPLY_TILE_DAMAGE : MultiplyTileDamageEffectAction.new(self),
	EFFECT.DEAL_DAMAGE : DealDamageEffectAction.new(self),
	EFFECT.POISON : PoisonEffectAction.new(self),
	EFFECT.ROOT : RootEffectAction.new(self),
	EFFECT.GROW_BIOME : GrowBiomeEffectAction.new(self),
	EFFECT.GAIN_TEMPORARY_VOID_CHARGES : GainTemporaryVoidChargeEffectAction.new(self),
	EFFECT.MONSTER_WEAKNESS : MonsterWeaknessEffectAction.new(self),
	EFFECT.MONSTER_DAMAGE_REDUCTION : MonsterDamageReductionEffectAction.new(self),
	EFFECT.FIRE : FireEffectAction.new(self),
	EFFECT.EVOLVE : EvolveEffectAction.new(self),
	EFFECT.DEVOLVE : DevolveEffectAction.new(self),
	EFFECT.BEACON_HEAL : BeaconHealEffectAction.new(self),
	EFFECT.BEACON_SHIELD : BeaconShieldEffectAction.new(self),
	EFFECT.TRIGGER_RANDOM_TILE : TriggerRandomTileEffectAction.new(self),
	EFFECT.TRIGGER_ALL_TILES : TriggerAllTilesEffectAction.new(self),
	EFFECT.PLACE_TILE : PlaceTileEffectAction.new(self),
	EFFECT.REMOVE_TILE : RemoveTileEffectAction.new(self),
	EFFECT.FILL_WITH_TILE : FillWithTileEffectAction.new(self),
	EFFECT.FILL_WITH_TILE_OR_EVOLVE : FillWithTileOrEvolveEffectAction.new(self),
	EFFECT.INCREASE_MAX_RANGE : IncreaseMaxRangeEffectAction.new(self),
}

## Descriptions
var trigger_descriptions : Dictionary[TileDataManager.TRIGGERS, String] = {
	TileDataManager.TRIGGERS.ON_MONSTER_WALK : "When an enemy enters",
	TileDataManager.TRIGGERS.ON_RESOLUTION_START : "At the start of the resolution phase",
	TileDataManager.TRIGGERS.ON_RESOLUTION_END : "At the end of the resolution phase",
	TileDataManager.TRIGGERS.ON_MONSTER_DEATH : "When a monster dies in range",
	TileDataManager.TRIGGERS.ON_TILE_PLACED : "When a land tile is placed in range",
	TileDataManager.TRIGGERS.ON_BEACON_DAMAGE : "When the beacon is damaged",
}

## Hide useless fields
const values_always_displayed : Array[StringName] = [&"trigger", &"title", &"description", &"icon", &"effect"];
const value_per_effect : Dictionary[EFFECT, StringName] = {
	EFFECT.INCREASE_TILE_DAMAGE : &"value",
	EFFECT.INCREASE_RANGED_TILE_DAMAGE : &"value",
	EFFECT.MULTIPLY_TILE_DAMAGE : &"value",
	EFFECT.DEAL_DAMAGE : &"value",
	EFFECT.POISON : &"value",
	EFFECT.ROOT : &"value",
	EFFECT.GROW_BIOME : &"tile_value",
	EFFECT.GAIN_TEMPORARY_VOID_CHARGES : &"value",
	EFFECT.MONSTER_WEAKNESS : &"value",
	EFFECT.MONSTER_DAMAGE_REDUCTION : &"value",
	EFFECT.FIRE : &"value",
	EFFECT.EVOLVE : &"value",
	EFFECT.DEVOLVE : &"value",
	EFFECT.BEACON_HEAL : &"value",
	EFFECT.BEACON_SHIELD : &"value",
	EFFECT.TRIGGER_RANDOM_TILE : &"value",
	EFFECT.TRIGGER_ALL_TILES : &"value",
	EFFECT.PLACE_TILE : &"tile_value",
	EFFECT.REMOVE_TILE : &"tile_value",
	EFFECT.FILL_WITH_TILE : &"tile_value",
	EFFECT.FILL_WITH_TILE_OR_EVOLVE : &"tile_value",
	EFFECT.INCREASE_MAX_RANGE : &"value",
}

func _validate_property(property : Dictionary) -> void:
	if value_per_effect[effect] == property.name or values_always_displayed.has(property.name):
		property.usage |= PROPERTY_USAGE_EDITOR
	else:
		property.usage &= ~PROPERTY_USAGE_EDITOR

func execute(_trigger : TileDataManager.TRIGGERS, tile_position : Vector2i, tile_data : CustomTileData):
	if trigger != _trigger or _trigger == TileDataManager.TRIGGERS.ANY: return;
	
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
	return trigger_descriptions[trigger] + ", " + effect_actions[effect].get_description() % get_value_to_string();
