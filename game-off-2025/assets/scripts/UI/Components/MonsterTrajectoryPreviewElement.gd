class_name MonsterTrajectoryPreviewElement extends Control

const monster_trajectory_preview_scene : PackedScene = preload("res://scenes/components/MonsterTrajectoryPreviewElement.tscn");

@export_group("Components")
@export var ranged_offset : MarginContainer;
@export var tile_preview : TextureRect;
@export var preview_damage_separator : Label;
@export var monster_damage_info : MonsterInfo;
@export var damage_effect_separator : Label;
@export var effect_container : HBoxContainer;

static func create_monster_trajectory_info(tile_position : Vector2i, is_ranged : bool) -> MonsterTrajectoryPreviewElement:
	var monster_trajectory_preview = monster_trajectory_preview_scene.instantiate();
	var must_be_displayed = monster_trajectory_preview.setup(tile_position, is_ranged);
	return monster_trajectory_preview if must_be_displayed else null;

func setup(tile_position : Vector2i, is_ranged : bool) -> bool:
	if !MainTilemap.instance.tiles.has(tile_position): 
		tile_preview.texture.region = TileDataManager.tile_dictionnary["empty-tile"].get_texture_region();
		preview_damage_separator.visible = false;
		monster_damage_info.visible = false;
		damage_effect_separator.visible = false;
		effect_container.visible = false;
		ranged_offset.visible = is_ranged;
		return true;
	
	var tile_data = MainTilemap.instance.tiles[tile_position];
	if tile_position == Vector2i.ZERO:
		tile_preview.texture = TileDataManager.beacon_icon_small;
		preview_damage_separator.visible = false;
		monster_damage_info.visible = false;
		damage_effect_separator.visible = false;
		effect_container.visible = false;
	else:
		tile_preview.texture.region = tile_data.get_texture_region();
	
	ranged_offset.visible = is_ranged;
	var damage_icon_texture = TileDataManager.ranged_damage_icon_small if is_ranged else TileDataManager.damage_icon_small;
	monster_damage_info.setup(str(tile_data.damage), damage_icon_texture);
	var added_effect = false;
	for effect in tile_data.effects:
		if effect.trigger != TileDataManager.TRIGGERS.ON_MONSTER_WALK: continue;
		
		added_effect = true;
		var effect_sprite = TextureRect.new();
		effect_sprite.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED;
		effect_sprite.texture = effect.icon;
		effect_container.add_child(effect_sprite);
	if !added_effect:
		damage_effect_separator.visible = false;
		effect_container.visible = false;
	return !is_ranged or added_effect or tile_data.damage > 0;
