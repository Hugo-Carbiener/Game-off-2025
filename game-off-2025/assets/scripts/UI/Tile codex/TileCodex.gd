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
@export var close_bookmark_texture : Texture2D;
@export var return_bookmark_texture : Texture2D;
@export_group("Misc")
@export var damage_effect_tooltip : EffectTooltip;
@export var requirements_tilemap : TileMapLayer;
 
var current_tile_data : CustomTileData;
var current_tile_index : int = 0;
var bookmarks : Array[TileCodexBookmark];
var tile_card : TileCard;
var effect_tooltips : Array[EffectTooltip];
var evolutions : Array[TileCardEvolution];
var previous_tiles : Array[String];
var timer : Timer;

func _ready() -> void:
	SignalBus.bookmark_clicked.connect(setup);
	SignalBus.summary_element_clicked.connect(setup);
	setup("");

func setup(tile_id : String):
	reset();
	if TileDataManager.tile_dictionnary.has(tile_id):
		current_tile_data = TileDataManager.tile_dictionnary[tile_id];
		init_tile_detail_page(current_tile_data);
	else:
		init_summary();

func init_summary():
	summary_left_page.visible = true;
	left_page.visible = false;
	effects_area.visible = false;
	evolutions_area.visible = false;
	requirements_area.visible = false;
	init_bookmarks("");
	init_movement_buttons("");
	for tile in TileDataManager.land_tiles:
		var summary_element = TileCodexSummaryElement.create_tile_codex_summary_element(tile);
		summary_elements_container.add_child(summary_element);

func init_tile_detail_page(tile_data : CustomTileData):
	summary_left_page.visible = false;
	left_page.visible = true;
	effects_area.visible = true;
	evolutions_area.visible = true;
	requirements_area.visible = true;
	if !TileDataManager.known_tiles.has(tile_data.id):
		tile_data = TileDataManager.tile_dictionnary["unknown"];
	init_left_page(tile_data);
	init_right_page(tile_data);
	init_movement_buttons(tile_data.id);

func init_left_page(tile_data : CustomTileData):
	init_bookmarks(tile_data.id);
	init_favorite_button(tile_data.id);
	init_title(tile_data.name);
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
		summary_bookmark.button_up.connect(setup.bind(""));

func init_close_bookmark(tile_id : String):
	if previous_tiles.is_empty() or tile_id == "":
		close_bookmark_icon.texture = close_bookmark_texture;
		if !close_bookmark.button_up.has_connections():
			close_bookmark.button_up.connect(close_codex);
	else :
		close_bookmark_icon.texture = return_bookmark_texture;
		if !close_bookmark.button_up.has_connections():
			close_bookmark.button_up.connect(return_to_previous_tile);

func init_bookmarks(tile_id : String):
	reset_bookmarks();
	init_summary_bookmark(tile_id);
	init_close_bookmark(tile_id);
	for target_tile_id in UserSettings.tile_codex_bookmarks:
		var bookmark = TileCodexBookmark.create_tile_codex_bookmark(target_tile_id);
		if target_tile_id == tile_id:
			bookmark.button_pressed = true;
		bookmark_container.add_child(bookmark);
		bookmarks.push_back(bookmark);

func init_favorite_button(tile_id : String):
	update_favorite_button_style(tile_id);
	if favorite_button.button_up.has_connections():
		for connection in favorite_button.button_up.get_connections():
			favorite_button.button_up.disconnect(connection["callable"]);
	favorite_button.button_up.connect(toggle_favorite.bind(tile_id));

func update_favorite_button_style(tile_id : String):
	favorite_button.button_pressed = UserSettings.tile_codex_bookmarks.has(tile_id);

func init_title(tile_name : String):
	title_label.text = tile_name;

func init_card(tile_id : String):
	var _tile_card = TileCard.create_tile_card(tile_id, false).without_count_overlay();
	tile_card_container.add_child(_tile_card);
	tile_card = _tile_card;

func init_number(tile_id : String):
	var tile_to_consider = current_tile_data.id if current_tile_data != null else tile_id;
	current_tile_index = TileDataManager.land_tiles.find(tile_to_consider);
	number_label.text = str(current_tile_index + 1) + "/" + str(TileDataManager.land_tiles.size());

func init_description(tile_data : CustomTileData):
	description_label.text = tile_data.description;

func init_effects(tile_data : CustomTileData):
	effects_area.visible = tile_data.damage > 0 or !tile_data.effects.is_empty();
	if !effects_area.visible: return;
	
	damage_effect_tooltip.visible = tile_data.damage > 0;
	for effect in tile_data.effects:
		var effect_toolitp = EffectTooltip.create_tooltip(effect);
		effects_container.add_child(effect_toolitp);
		effect_tooltips.push_back(effect_toolitp);

func init_evolutions(tile_data : CustomTileData):
	evolutions_area.visible = !tile_data.evolutions.is_empty();
	if !evolutions_area.visible: return;
	
	for evolution in tile_data.evolutions:
		var evolution_tile_data = TileDataManager.tile_dictionnary[evolution];
		if evolution_tile_data == null: continue;
		
		var tile_card_evolution = TileCardEvolution.create_tile_card_evolution(evolution_tile_data).with_clickable_evolutions(on_evolution_click);
		evolutions_container.add_child(tile_card_evolution);
		evolutions.push_back(tile_card_evolution);
		tile_card_evolution.init_color(tile_data.color);

func on_evolution_click(target_tile_id : String):
	var current_tile_id = TileDataManager.land_tiles[current_tile_index];
	previous_tiles.push_back(current_tile_id);
	setup(target_tile_id);

func init_requirements(tile_data : CustomTileData):
	requirements_area.visible = tile_data.requirement != null and tile_data.requirement.has_requirement();
	if tile_data.requirement == null or !tile_data.requirement.has_requirement() or tile_data.devolutions.is_empty(): return; 
	timer = Timer.new();
	add_child(timer);
	timer.timeout.connect(set_random_requirement_preview.bind(tile_data));
	timer.start(Constants.requirements_update_delay)
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
		tile_card.queue_free();
	for effect in effect_tooltips:
		effect.queue_free();
	effect_tooltips.clear();
	for evolution in evolutions:
		evolution.queue_free();
	evolutions.clear();
	for summary_element in summary_elements_container.get_children():
		summary_element.queue_free();
	if timer != null:
		timer.queue_free();

func reset_bookmarks():
	for bookmark in bookmarks:
		bookmark.queue_free();
	bookmarks.clear();
	for connection in close_bookmark.button_up.get_connections():
		close_bookmark.button_up.disconnect(connection["callable"]);

## ACTIONS 

func toggle_favorite(tile_id : String):
	if !favorite_button.button_pressed:
		UserSettings.tile_codex_bookmarks.erase(tile_id);
	else:
		if UserSettings.tile_codex_bookmarks.size() >= Constants.max_bookmarks:
			favorite_button.button_pressed = false;
			printerr("Max bookmark amount reached.");
			# TODO: Implement tooltip to warn player
			return;
			
		if !UserSettings.tile_codex_bookmarks.has(tile_id):
			UserSettings.tile_codex_bookmarks.push_back(tile_id);
	init_bookmarks(tile_id);
	update_favorite_button_style(tile_id);

func next_tile():
	if current_tile_index + 1 >= TileDataManager.land_tiles.size(): return;
	
	var next_tile_id = TileDataManager.land_tiles[current_tile_index + 1];
	setup(next_tile_id);

func previous_tile():
	var next_tile_id = TileDataManager.land_tiles[current_tile_index - 1] if current_tile_index > 0 else "";
	setup(next_tile_id);

func return_to_previous_tile():
	if previous_tiles.is_empty(): return;
	
	var next_tile_id = previous_tiles.pop_back();
	setup(next_tile_id);

func close_codex():
	SceneLoader.switch_scene_with_transition(SceneLoader.load_game_scene(), Vector2i.RIGHT);
