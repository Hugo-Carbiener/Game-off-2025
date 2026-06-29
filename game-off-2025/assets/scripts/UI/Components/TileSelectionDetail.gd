class_name TileSelectionDetail extends Control

const METADATA_KEY = "types";
const METADATA_VALUE_MONSTER = "monster";
const METADATA_VALUE_TILE = "tile";
const METADATA_VALUE_BREACH = "breach";

@export_group("Components")
@export var selection_preview : TextureRect;
@export var title_label : Label;
@export var health_label : Label;
@export var weakness_label : Label;
@export var damage_label : Label;
@export var damage_boost_label : Label;
@export var damage_multiplier_label : Label;
@export var damage_decrease_label : Label;
@export var range_label : Label;
@export var range_boost_label : Label;
@export var effects_container : HBoxContainer;
@export var trajectory_container : GridContainer;
@export var trajectory_preview_container : VBoxContainer;
@export var maturity_counter_label : Label;
@export var breach_intent_effect_preview : EffectPreview;
@export var instability_meter : InstabilityMeter;
@export var instability_text_value : Label;
@export var instability_text_max_value : Label;
@export var codex_link_button : TextureButton;
@export_group("Component groups")
@export var lines_list : Array[Control];
@export var health_weakness_line_container : Control;
@export var effects_line_container : Control;
@export var breach_intent_line : Control;
@export var maturity_line : Control;

func _ready() -> void:
	SignalBus.tile_selected.connect(on_tile_selection);
	SignalBus.tile_unselected.connect(on_tile_unselection);
	SignalBus.breach_instability_changed.connect(on_breach_instability_changed);

func on_tile_selection(tile_position : Vector2i):
	if MonsterFactory.monsters.has(tile_position):
		var monster = MonsterFactory.monsters[tile_position];
		setup_from_monster(monster);
	elif MainTilemap.instance.tiles.has(tile_position):
		var tile_data = MainTilemap.instance.tiles[tile_position];
		var dynamic_tile_data = MainTilemap.instance.tiles_dynamic_data[tile_position];
		setup_from_tile(tile_data, dynamic_tile_data);
	elif MonsterFactory.breaches.has(tile_position):
		setup_from_breach(MonsterFactory.breaches[tile_position]);
	else:
		return;
	visible = true;

func on_tile_unselection(_tilemap_position : Vector2i):
	visible = false;

func setup_from_tile(tile_data : CustomTileData, tile_dynamic_data : DynamicTileData):
	selection_preview.texture.region = tile_data.get_texture_region();
	selection_preview.self_modulate = Color.WHITE;

	title_label.text = tile_data.name;
	damage_label.text = str(tile_data.damage);
	var damage_boost_text = "+" + str(tile_dynamic_data.damage_boost) if tile_dynamic_data.damage_boost > 0 else ""; 
	damage_boost_label.text = damage_boost_text;
	var damage_multiplier_text = "x" + str(tile_dynamic_data.damage_multiplier) if tile_dynamic_data.damage_multiplier > 1 else "";
	damage_multiplier_label.text = damage_multiplier_text;
	damage_decrease_label.text = "";
	range_label.text = tile_data.effect_range.range_to_string();
	var range_boost_text = "+" + str(tile_dynamic_data.range_boost) if tile_dynamic_data.range_boost > 0 else "";
	range_boost_label.text = range_boost_text;
	
	for tile_effect_preview in effects_container.get_children():
		tile_effect_preview.queue_free();
	
	for tile_effect in tile_data.effects:
		var effect_preview = EffectPreview.create_effect_preview(tile_effect);
		effects_container.add_child(effect_preview);
	
	for connection in codex_link_button.button_up.get_connections():
		codex_link_button.button_up.disconnect(connection["callable"]);
	#codex_link_button.button_up.connect() #TODO : link codex button
	
	setup_visibility(METADATA_VALUE_TILE);
	effects_line_container.visible = !tile_data.effects.is_empty();

func setup_from_monster(monster : Monster):
	selection_preview.texture.region = TileDataManager.tile_dictionnary[Constants.TILE_DICT_MONSTER_KEY].get_texture_region();
	selection_preview.self_modulate = Color.WHITE;

	title_label.text = "Monster";
	health_label.text = str(monster.health);
	weakness_label.text = str(monster.health_weakness);
	damage_label.text = str(monster.health);
	damage_boost_label.text = "";
	damage_multiplier_label.text = "";
	var damage_decrease_text = "+" + str(monster.damage_weakness) if monster.damage_weakness > 0 else "";
	damage_decrease_label.text = damage_decrease_text;
	range_boost_label.text = "";
	
	setup_monster_trajectory(monster);
	setup_visibility(METADATA_VALUE_MONSTER);
	health_weakness_line_container.visible = monster.health_weakness > 0;

func setup_monster_trajectory(monster : Monster):
	reset_trajectory();
	for tile_position in monster.trajectory:
		if tile_position == monster.tilemap_position: continue;
		
		setup_monster_trajectory_element(tile_position);
		setup_monster_trajectory_preview_element(tile_position);

func setup_monster_trajectory_element(tile_position : Vector2i):
	var tile_data : CustomTileData;
	if tile_position == Vector2i.ZERO: return;
	if MainTilemap.instance.has_tile_at(tile_position):
		tile_data = MainTilemap.instance.tiles[tile_position];
	else :
		tile_data = TileDataManager.tile_dictionnary["empty-tile"];
	trajectory_container.add_child(TilePreview.create_tile_preview(tile_data));

func setup_monster_trajectory_preview_element(tile_position : Vector2i):
	var trajectory_preview = MonsterTrajectoryPreviewElement.create_monster_trajectory_info(tile_position, false);
	if trajectory_preview != null:
		trajectory_preview_container.add_child(trajectory_preview);
	if MainTilemap.instance.tiles_dynamic_data.has(tile_position):
		for targetting_tile_position in MainTilemap.instance.tiles_dynamic_data[tile_position].targetted_by:
			trajectory_preview = MonsterTrajectoryPreviewElement.create_monster_trajectory_info(targetting_tile_position, true);
			if trajectory_preview != null:
				trajectory_preview_container.add_child(trajectory_preview);

func reset_trajectory():
	for child in trajectory_container.get_children():
		child.queue_free();
	for child in trajectory_preview_container.get_children():
		child.queue_free();

func setup_from_breach(breach : Breach):
	selection_preview.texture.region = breach.get_breach_texture_region();
	selection_preview.self_modulate = breach.modulate;
	title_label.text = breach.breach_data.name;
	
	maturity_counter_label.text = str(Constants.breach_setup_delay - breach.age + 1);
	instability_text_value.text = str(breach.instability);
	instability_text_max_value.text = str(Constants.breach_max_instability);
	instability_meter.setup(breach.instability);
	breach_intent_effect_preview.setup(breach.get_intent_effect());
	setup_visibility(METADATA_VALUE_BREACH);
	breach_intent_line.visible = breach.is_mature();
	maturity_line.visible = !breach.is_mature();

func on_breach_instability_changed(tilemap_position : Vector2i, instability_value : int):
	if visible == false or tilemap_position != TileSelector.instance.selected_tile: return
	
	AnimationUtils.animate_integer(
		func(x): instability_text_value.text = str(x),
		int(instability_meter.meter.value),
		instability_value,
		Constants.default_transition_duration
	);
	instability_meter.transition_value(instability_value);

func setup_visibility(type : String):
	for line in lines_list:
		var metadata = line.get_meta("types");
		line.visible = metadata.has(type);
