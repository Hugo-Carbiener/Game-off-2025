class_name TileSelectionDetail extends Control

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
@export var codex_link_button : TextureButton;
@export_group("Component groups")
@export var health_line_container : Control;
@export var health_weakness_line_container : Control;
@export var damage_line_container : Control;
@export var range_line_container : Control;
@export var effects_line_container : Control;
@export var trajectory_line_container : Control;
@export var trajectory_preview_line_container : Control;
@export var codex_link_container : Control;

func _ready() -> void:
	SignalBus.tile_selected.connect(on_tile_selection);
	SignalBus.tile_unselected.connect(on_tile_unselection);

func on_tile_selection(tile_position : Vector2i):
	if MonsterFactory.monsters.has(tile_position):
		var monster = MonsterFactory.monsters[tile_position];
		setup_from_monster(monster);
	elif MainTilemap.instance.tiles.has(tile_position):
		var tile_data = MainTilemap.instance.tiles[tile_position];
		var dynamic_tile_data = MainTilemap.instance.tiles_dynamic_data[tile_position];
		setup_from_tile(tile_data, dynamic_tile_data);
	elif MonsterFactory.breaches.has(tile_position):
		setup_from_breach();
	else:
		return;
	visible = true;

func on_tile_unselection():
	visible = false;

func setup_from_tile(tile_data : CustomTileData, tile_dynamic_data : DynamicTileData):
	selection_preview.texture.region = tile_data.get_texture_region();
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
	
	for effect_idx in range(tile_data.effects.size()):
		var icon = effects_container.get_child(effect_idx);
		if effect_idx >= tile_data.effects.size():
			icon.visible = false;
		else :
			icon.texture = tile_data.effects[effect_idx].icon;
			icon.visible = true;
	
	for connection in codex_link_button.button_up.get_connections():
		codex_link_button.button_up.disconnect(connection["callable"]);
	#codex_link_button.button_up.connect()
	
	health_line_container.visible = false;
	damage_line_container.visible = true;
	range_line_container.visible = true;
	effects_line_container.visible = !tile_data.effects.is_empty();
	trajectory_line_container.visible = false;
	trajectory_preview_line_container.visible = false;
	codex_link_container.visible = true;

func setup_from_monster(monster : Monster):
	selection_preview.texture.region = TileDataManager.tile_dictionnary[Constants.TILE_DICT_MONSTER_KEY].get_texture_region();
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
	health_line_container.visible = true;
	health_weakness_line_container.visible = monster.health_weakness > 0;
	damage_line_container.visible = true;
	range_line_container.visible = false;
	effects_line_container.visible = false;
	trajectory_line_container.visible = true;
	trajectory_preview_line_container.visible = true;
	codex_link_container.visible = false;

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

func setup_from_breach():
	pass;
