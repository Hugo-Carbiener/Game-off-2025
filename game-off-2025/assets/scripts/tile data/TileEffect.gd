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
}

var effect_actions : Dictionary[EFFECT, Callable] = {
	EFFECT.INCREASE_TILE_DAMAGE : increase_tile_damage,
	EFFECT.INCREASE_RANGED_TILE_DAMAGE : increase_ranged_tile_damage,
	EFFECT.MULTIPLY_TILE_DAMAGE : multiply_tile_damage,
	EFFECT.DEAL_DAMAGE : deal_damage,
	EFFECT.POISON : poison,
	EFFECT.ROOT : root,
	EFFECT.GROW_BIOME : grow_biome,
	EFFECT.GAIN_TEMPORARY_VOID_CHARGES : gain_temporary_void_charge,
}

## Descriptions
var trigger_descriptions : Dictionary[TileDataManager.TRIGGERS, String] = {
	TileDataManager.TRIGGERS.ON_MONSTER_WALK : "When an enemy enters",
	TileDataManager.TRIGGERS.ON_RESOLUTION_START : "At the start of the resolution phase",
	TileDataManager.TRIGGERS.ON_RESOLUTION_END : "At the end of the resolution phase",
	TileDataManager.TRIGGERS.ON_MONSTER_DEATH : "When a monster dies in range",
	TileDataManager.TRIGGERS.ON_APPARITION : "When this land tile is placed",
}

var effect_descriptions : Dictionary[EFFECT, String] = {
	EFFECT.INCREASE_TILE_DAMAGE : "increase the damage of land tiles by %s.",
	EFFECT.INCREASE_RANGED_TILE_DAMAGE : "increase the damage of ranged land tiles by %s.",
	EFFECT.MULTIPLY_TILE_DAMAGE : "multiply the damage of land tiles by %s.",
	EFFECT.DEAL_DAMAGE : "deals %S damages.",
	EFFECT.POISON : "applies poison for %s turns.",
	EFFECT.ROOT : "roots enemies for %s turns.",
	EFFECT.GROW_BIOME : "extends the biome with %s.",
	EFFECT.GAIN_TEMPORARY_VOID_CHARGES : "gains %s temporary void charges.",
}

## Hide useless fields
const values_always_displayed : Array[StringName] = [&"trigger", &"title", &"description", &"icon", &"effect"];
const values_group_always_displayed : Array[StringName] = [&"Effect variables", &"Trigger"];
const value_per_effect : Dictionary[EFFECT, StringName] = {
	EFFECT.INCREASE_TILE_DAMAGE : &"value",
	EFFECT.INCREASE_RANGED_TILE_DAMAGE : &"value",
	EFFECT.MULTIPLY_TILE_DAMAGE : &"value", 
	EFFECT.DEAL_DAMAGE : &"value",
	EFFECT.POISON : &"value",
	EFFECT.ROOT : &"value",
	EFFECT.GROW_BIOME : &"tile_value",
	EFFECT.GAIN_TEMPORARY_VOID_CHARGES : &"value",
}

func _validate_property(property : Dictionary) -> void:
	if value_per_effect[effect] == property.name or values_always_displayed.has(property.name):
		property.usage |= PROPERTY_USAGE_EDITOR
	else:
		property.usage &= ~PROPERTY_USAGE_EDITOR

func execute(tile_position : Vector2i, tile_data : CustomTileData):
	if !effect_actions.has(effect):
		printerr("Effect " + str(effect) + " has no action.");
		return;
	
	effect_actions[effect].call(tile_position, tile_data);

func increase_tile_damage(tile_position : Vector2i, tile_data : CustomTileData):
	for offset_coords in tile_data.get_cells_in_range():
		if !MainTilemap.instance.has_tile_at(tile_position + offset_coords): continue;
		
		MainTilemap.instance.tiles_dynamic_data[tile_position + offset_coords].damage_boost += value;

func increase_ranged_tile_damage(tile_position : Vector2i, tile_data : CustomTileData):
	for offset_coords in tile_data.get_cells_in_range():
		if !MainTilemap.instance.has_tile_at(tile_position + offset_coords): continue;
		
		var target_tile_data = MainTilemap.instance.tiles[tile_position + offset_coords];
		if target_tile_data.effect_range.is_ranged(): 
			MainTilemap.instance.tiles_dynamic_data[tile_position + offset_coords].damage_boost += value;

func multiply_tile_damage(tile_position : Vector2i, tile_data : CustomTileData):
	for offset_coords in tile_data.get_cells_in_range():
		if !MainTilemap.instance.has_tile_at(tile_position + offset_coords): continue;
		
		MainTilemap.instance.tiles_dynamic_data[tile_position + offset_coords].damage_multiplier += value;

func deal_damage(tile_position : Vector2i, tile_data : CustomTileData):
	for offset_coords in tile_data.get_cells_in_range():
		if !MonsterFactory.monsters.has(tile_position + offset_coords): continue;
		
		MonsterFactory.monsters[tile_position + offset_coords].damage(value);

func poison(tile_position : Vector2i, tile_data : CustomTileData):
	pass;

func root(tile_position : Vector2i, tile_data : CustomTileData):
	pass;

func grow_biome(tile_position : Vector2i, tile_data : CustomTileData):
	pass;

func gain_temporary_void_charge(tile_position : Vector2i, tile_data : CustomTileData):
	pass;

func get_value() -> String:
	if value != 0:
		return str(value);
	
	if tile_value != null && tile_value != "":
		return tile_value;
	
	printerr("No valid value on effect " + resource_name + " at " + resource_path);
	return "";

func get_description() -> String:
	return trigger_descriptions[trigger] + ", " + effect_descriptions[effect] % get_value();
