extends Control
class_name TileCodex

@export_group("Pages")
@export var left_page : Control;
@export var right_page : Control;
@export var summary_left_page : Control;
@export_group("Hideable parts")
@export var effects_area : Control;
@export var evolutions_area : Control;
@export var requirements_area : Control;
@export_group("Containers")
@export var bookmark_container : Control;
@export var tile_card_container : Control;
@export var effects_container : Control;
@export var evolutions_container : Control;
@export var summary_elements_container : GridContainer;
@export_group("Texts")
@export var title_label : Label;
@export var number_label : Label;
@export var description_label : Label;
@export_group("Buttons")
@export var previous_button : TextureButton;
@export var next_button : TextureButton;
@export var favorite_button : ToggleButton;
@export_group("Bookmarks")
@export var summary_bookmark : TileCodexBookmark;
@export var close_bookmark : TileCodexBookmark;
@export var close_bookmark_icon : TextureRect;
@export var close_bookmark_tile_icon : TextureRect;
@export var close_bookmark_texture : Texture2D;
@export_group("Misc")
@export var damage_effect_tooltip : EffectTooltipContent;
@export var requirements_tilemap : TileMapLayer;
@export var requirement_timer : Timer;
@export var requirement_shader : TextureRect;
@export_group("Reveal animation")
@export var fade_out_duration : float;
@export var fade_in_duration : float;
@export var new_page_pause_duration : float;
@export var card_half_rotation_duration : float;
 
var current_tile_data : CustomTileData;
var current_tile_index : int = 0;
var bookmarks : Array[TileCodexBookmark];
var tile_card : TileCard;
var effect_tooltips : Array[EffectTooltipContent];
var evolutions : Array[TileCardEvolution];
var previous_tiles : Array[String];
var timer : Timer;

func _ready() -> void:
	SignalBus.bookmark_clicked.connect(setup);
	SignalBus.summary_element_clicked.connect(setup);
	var displayed_new_cards = await discover_new_tiles();
	
	if !displayed_new_cards:
		setup("");

func setup(tile_id : String):
	reset();
	if TileDataManager.tile_dictionnary.has(tile_id):
		current_tile_data = TileDataManager.tile_dictionnary[tile_id];
		init_tile_detail_page(current_tile_data);
	else:
		init_summary();

static func store_new_tile(tile_id):
	if UserData.tile_codex_save.pages_to_discover.has(tile_id) : return;
	
	UserData.tile_codex_save.pages_to_discover.append(tile_id);

func discover_new_tiles() -> bool:
	if UserData.tile_codex_save.pages_to_discover.is_empty(): return false;
	
	UserSettings.are_input_blocked = true;
	for tile_to_discover in UserData.tile_codex_save.pages_to_discover:
		await reveal_card(tile_to_discover);
	UserData.tile_codex_save.pages_to_discover.clear();
	UserSettings.are_input_blocked = false;
	return true;

func init_summary():
	init_modules_visibility(false);
	init_bookmarks("");
	init_movement_buttons("");
	for tile in TileDataManager.land_tiles:
		var summary_element = TileCodexSummaryElement.create_tile_codex_summary_element(tile);
		summary_elements_container.add_child(summary_element);

func init_tile_detail_page(tile_data : CustomTileData):
	init_modules_visibility(true);
	init_left_page(tile_data);
	init_right_page(tile_data);
	init_movement_buttons(tile_data.id);

func init_modules_visibility(_visible : bool):
	summary_left_page.visible = !_visible;
	left_page.visible = _visible;
	effects_area.visible = _visible;
	evolutions_area.visible = _visible;
	requirements_area.visible = _visible;

func init_left_page(tile_data : CustomTileData):
	init_bookmarks(tile_data.id);
	init_favorite_button(tile_data.id);
	init_title(tile_data);
	init_card(tile_data.id);
	init_number(tile_data.id);
	init_description(tile_data);

func init_right_page(tile_data : CustomTileData):
	init_effects(tile_data);
	init_evolutions(tile_data);
	init_requirements(tile_data);

func init_movement_buttons(tile_id : String):
	next_button.disabled = current_tile_index == TileDataManager.land_tiles.size() - 1;
	previous_button.disabled = tile_id == "";
	if !next_button.disabled and !next_button.button_up.has_connections():
		next_button.button_up.connect(next_tile);
	if !previous_button.disabled and !previous_button.button_up.has_connections():
		previous_button.button_up.connect(previous_tile);

func init_summary_bookmark(tile_id : String):
	summary_bookmark.button_pressed = tile_id == "";
	if !summary_bookmark.button_up.has_connections():
		summary_bookmark.button_up.connect(open_codex_summary);

func init_close_bookmark(tile_id : String):
	if previous_tiles.is_empty() or tile_id == "":
		close_bookmark_icon.visible = true;
		close_bookmark_tile_icon.visible = false;
		close_bookmark_icon.texture = Texture2D.new();
		close_bookmark_icon.texture = close_bookmark_texture;
		if !close_bookmark.button_up.has_connections():
			close_bookmark.button_up.connect(close_codex);
	else:
		var tile_data = TileDataManager.tile_dictionnary[previous_tiles[previous_tiles.size() - 1]];
		if tile_data == null: return;
		
		close_bookmark_icon.visible = false;
		close_bookmark_tile_icon.visible = true;
		close_bookmark_tile_icon.texture.region = tile_data.get_texture_region();
		if !close_bookmark.button_up.has_connections():
			close_bookmark.button_up.connect(return_to_previous_tile);

func init_bookmarks(tile_id : String):
	reset_bookmarks();
	init_summary_bookmark(tile_id);
	init_close_bookmark(tile_id);
	for target_tile_id in UserData.tile_codex_save.bookmarks:
		var bookmark = TileCodexBookmark.create_tile_codex_bookmark(target_tile_id);
		if target_tile_id == tile_id:
			bookmark.button_pressed = true;
		bookmark_container.add_child(bookmark);
		bookmarks.append(bookmark);

func init_favorite_button(tile_id : String):
	update_favorite_button_style(tile_id);
	if favorite_button.button_up.has_connections():
		for connection in favorite_button.button_up.get_connections():
			favorite_button.button_up.disconnect(connection["callable"]);
	favorite_button.button_up.connect(toggle_favorite.bind(tile_id));

func update_favorite_button_style(tile_id : String):
	favorite_button.button_pressed = UserData.tile_codex_save.bookmarks.has(tile_id);

func init_title(tile_data : CustomTileData):
	title_label.text = tile_data.name if UserData.get_known_tiles().has(tile_data.id) else TileDataManager.tile_dictionnary["unknown"].name;

func init_card(tile_id : String):
	if tile_card != null:
		tile_card.free();
		
	var _tile_card = TileCard.create_tile_card(tile_id, false);
	tile_card = _tile_card;
	tile_card_container.add_child(_tile_card);

func init_number(tile_id : String):
	var tile_to_consider = current_tile_data.id if current_tile_data != null else tile_id;
	current_tile_index = TileDataManager.land_tiles.find(tile_to_consider);
	number_label.text = str(current_tile_index + 1) + "/" + str(TileDataManager.land_tiles.size());

func init_description(tile_data : CustomTileData):
	var text = tile_data.description if UserData.get_known_tiles().has(tile_data.id) else TileDataManager.tile_dictionnary["unknown"].description;
	description_label.text = text;

func init_effects(tile_data : CustomTileData):
	effects_area.visible = UserData.get_known_tiles().has(tile_data.id) and (tile_data.damage > 0 or !tile_data.effects.is_empty());
	if !effects_area.visible: return;
	
	damage_effect_tooltip.visible = tile_data.damage > 0;
	for effect in tile_data.effects:
		var effect_toolitp = EffectTooltipContent.create_tooltip(effect);
		effects_container.add_child(effect_toolitp);
		effect_tooltips.append(effect_toolitp);

func init_evolutions(tile_data : CustomTileData):
	evolutions_area.visible = UserData.get_known_tiles().has(tile_data.id) and !tile_data.evolutions.is_empty();
	if !evolutions_area.visible: return;
	
	for evolution in tile_data.evolutions:
		var evolution_tile_data = TileDataManager.tile_dictionnary[evolution];
		if evolution_tile_data == null: continue;
		
		var tile_card_evolution = TileCardEvolution.create_tile_card_evolution(evolution_tile_data).with_clickable_evolutions(on_evolution_click);
		evolutions_container.add_child(tile_card_evolution);
		evolutions.append(tile_card_evolution);
		tile_card_evolution.init_color(tile_data.color);

func on_evolution_click(target_tile_id : String):
	var current_tile_id = TileDataManager.land_tiles[current_tile_index];
	previous_tiles.append(current_tile_id);
	setup(target_tile_id);

func init_requirements(tile_data : CustomTileData):
	requirements_area.visible = UserData.get_known_tiles().has(tile_data.id) and tile_data.requirement != null and tile_data.requirement.has_requirement();
	if tile_data.requirement == null or !tile_data.requirement.has_requirement() or tile_data.devolutions.is_empty(): return; 
	requirement_timer.timeout.connect(set_random_requirement_preview.bind(tile_data));
	requirement_timer.start(Constants.requirements_update_delay);
	set_random_requirement_preview(tile_data);

func set_random_requirement_preview(tile_data : CustomTileData):
	requirements_tilemap.clear();
	var central_tile = TileDataManager.tile_dictionnary[tile_data.devolutions.pick_random()];
	requirements_tilemap.set_cell(Vector2i.ZERO, 0, central_tile.atlas_coordinates);
	var requirements = tile_data.requirement.get_requirement();
	for cell_coordinates in requirements.keys():
		var target_tile_data = TileDataManager.tile_dictionnary[requirements[cell_coordinates]];
		requirements_tilemap.set_cell(cell_coordinates, 0, target_tile_data.atlas_coordinates);

func reset():
	reset_bookmarks();
	if tile_card != null:
		tile_card.free();
	for effect in effect_tooltips:
		effect.queue_free();
	effect_tooltips.clear();
	for evolution in evolutions:
		evolution.queue_free();
	evolutions.clear();
	for summary_element in summary_elements_container.get_children():
		summary_element.queue_free();
	for connection in tree_entered.get_connections():
		tree_entered.disconnect(connection["callable"]);
	for connection in requirement_timer.timeout.get_connections():
		requirement_timer.timeout.disconnect(connection["callable"]);

func reset_bookmarks():
	for bookmark in bookmarks:
		bookmark.queue_free();
	bookmarks.clear();
	for connection in close_bookmark.button_up.get_connections():
		close_bookmark.button_up.disconnect(connection["callable"]);

func reveal_card(tile_id : String):
	UserData.get_known_tiles().erase(tile_id);
	setup(tile_id);
	var tween = get_tree().create_tween();
	tween.set_parallel(true);
	tween.tween_property(title_label, "self_modulate:a", 0, fade_out_duration).set_ease(Tween.EASE_IN);
	tween.tween_property(description_label, "self_modulate:a", 0, fade_out_duration).set_ease(Tween.EASE_IN);
	tween.tween_property(tile_card, "scale:x", 0.05, card_half_rotation_duration).set_delay(fade_out_duration - card_half_rotation_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT);
	await tween.finished;
	UserData.get_known_tiles().append(tile_id);
	setup(tile_id);
	tile_card.modulate.a = 0;
	title_label.self_modulate.a = 0.0;
	description_label.self_modulate.a = 0.0;
	effects_area.modulate.a = 0.0;
	evolutions_area.modulate.a = 0.0;
	requirements_area.modulate.a = 0.0;
	requirement_shader.modulate.a = 0;
	var _tween = get_tree().create_tween();
	_tween.set_parallel(true);
	_tween.tween_callback(func(): tile_card.modulate.a = 1);
	_tween.tween_property(title_label, "self_modulate:a", 1.0, fade_in_duration).set_ease(Tween.EASE_IN);
	_tween.tween_property(description_label, "self_modulate:a", 1.0, fade_in_duration).set_ease(Tween.EASE_IN);
	_tween.tween_property(effects_area, "modulate:a", 1.0, fade_in_duration).set_ease(Tween.EASE_IN);
	_tween.tween_property(evolutions_area, "modulate:a", 1.0, fade_in_duration).set_ease(Tween.EASE_IN);
	_tween.tween_property(requirements_area, "modulate:a", 1.0, fade_in_duration).set_ease(Tween.EASE_IN);
	_tween.tween_property(requirement_shader, "modulate:a", 1.0, fade_in_duration).set_delay(fade_in_duration).set_ease(Tween.EASE_OUT);
	_tween.tween_property(tile_card, "scale:x", 1, card_half_rotation_duration).from(0.05)
	_tween.tween_interval(new_page_pause_duration);
	await _tween.finished;

## ACTIONS 

func toggle_favorite(tile_id : String):
	if UserSettings.are_input_blocked: return;
	
	if !favorite_button.button_pressed:
		UserData.tile_codex_save.bookmarks.erase(tile_id);
	else:
		if UserData.tile_codex_save.bookmarks.size() >= Constants.max_bookmarks:
			favorite_button.button_pressed = false;
			NotificationCenter.instance.notify_warning("Max bookmarks reached (Max: " + str(Constants.max_bookmarks) + ")");
			return;
		
		if !UserData.get_known_tiles().has(tile_id):
			favorite_button.button_pressed = false;
			NotificationCenter.instance.notify_warning("Cannot bookmark an undiscovered card");
			return;
		
		if !UserData.tile_codex_save.bookmarks.has(tile_id):
			UserData.tile_codex_save.bookmarks.append(tile_id);
	init_bookmarks(tile_id);
	update_favorite_button_style(tile_id);

func next_tile():
	if UserSettings.are_input_blocked: return;
	if current_tile_index + 1 >= TileDataManager.land_tiles.size(): return;
	
	var next_tile_id = TileDataManager.land_tiles[current_tile_index + 1];
	setup(next_tile_id);

func previous_tile():
	if UserSettings.are_input_blocked: return;
	
	var next_tile_id = TileDataManager.land_tiles[current_tile_index - 1] if current_tile_index > 0 else "";
	setup(next_tile_id);

func return_to_previous_tile():
	if UserSettings.are_input_blocked: return;
	if previous_tiles.is_empty(): return;
	
	var next_tile_id = previous_tiles.pop_back();
	setup(next_tile_id);

func open_codex_summary():
	if UserSettings.are_input_blocked: return;
	
	setup("");

func close_codex():
	if UserSettings.are_input_blocked: return;
	
	SceneLoader.load_scene_with_transition(SceneLoader.SCENES.GAME, Vector2i.RIGHT);
