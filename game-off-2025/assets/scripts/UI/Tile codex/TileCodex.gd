extends Control
class_name TileCodex

@export_group("Hidable parts")
@export var effects_area : Control;
@export var evolutions_area : Control;
@export_group("Containers")
@export var bookmark_container : Control;
@export var tile_card_container : Control;
@export var effects_container : Control;
@export var evolutions_container : Control;
@export_group("Texts")
@export var title_label : Label;
@export var number_label : Label;
@export var damage_label : Label;
@export var range_label : Label;
@export_group("Buttons")
@export var previous_button : TextureButton;
@export var next_button : TextureButton;
@export var favorite_button : ToggleButton;

@export var damage_effect_tooltip : EffectTooltip;
 
var current_tile_index : int;
var bookmarks : Array[TileCodexBookmark];
var tile_card : TileCard;
var effect_tooltips : Array[EffectTooltip];
var evolutions : Array[TileCardEvolution];

func setup(tile_id : String):
	reset();
	var tile_data = TileDataManager.instance.tile_dictionnary[tile_id];
	if tile_data == null:
		printerr("Failed to find tile data " + tile_id + " while instancing tile codex.");
		return;
	init_left_page(tile_data);
	init_right_page(tile_data);
	init_movement_buttons();

func init_left_page(tile_data : CustomTileData):
	init_bookmarks();
	init_favorite_button(tile_data.id);
	init_title(tile_data.name);
	init_card(tile_data.id);
	init_number(tile_data.id);
	init_stats(tile_data);

func init_right_page(tile_data : CustomTileData):
	init_effects(tile_data);
	init_evolutions(tile_data);

func init_movement_buttons():
	if !previous_button.button_up.has_connections():
		previous_button.button_up.connect(previous_tile);
	if !next_button.button_up.has_connections():
		next_button.button_up.connect(next_tile);

func init_bookmarks():
	for target_tile_id in UserSettings.tile_codex_bookmarks:
		var bookmark = TileCodexBookmark.create_tile_codex_tab(target_tile_id);
		bookmark_container.add_child(bookmark);
		bookmarks.push_back(bookmark);

func init_favorite_button(tile_id : String):
	favorite_button.button_pressed = UserSettings.tile_codex_bookmarks.has(tile_id);

func init_title(tile_name : String):
	title_label.text = tile_name;

func init_card(tile_id : String):
	var _tile_card = TileCard.create_tile_card(tile_id, false).without_count_overlay();
	tile_card_container.add_child(_tile_card);
	tile_card = _tile_card;

func init_number(tile_id : String):
	current_tile_index = TileDataManager.instance.land_tiles.find(tile_id);
	number_label.text = str(current_tile_index + 1) + "/" + str(TileDataManager.instance.land_tiles.size());

func init_stats(tile_data : CustomTileData):
	damage_label.text = str(tile_data.damage);
	range_label.text = tile_data.effect_range.range_to_string();

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
		#TODO : add new setup on evolution click + migrate stack feature
		var tile_card_evolution = TileCardEvolution.create_tile_card_evolution(tile_data).with_clickable_evolutions(func():return);
		evolutions_container.add_child(tile_card_evolution);
		evolutions.push_back(tile_card_evolution);

func reset():
	for bookmark in bookmarks:
		bookmark.queue_free();
	bookmarks.clear();
	if tile_card != null:
		tile_card.queue_free();
	for effect in effect_tooltips:
		effect.queue_free();
	effect_tooltips.clear();
	for evolution in evolutions:
		evolution.queue_free();
	evolutions.clear();

## ACTIONS 

func next_tile():
	if current_tile_index + 1 >= TileDataManager.instance.land_tiles.size(): return;
	
	var next_tile_id = TileDataManager.instance.land_tiles[current_tile_index + 1];
	setup(next_tile_id);

func previous_tile():
	if current_tile_index <= 0: return;
	
	var next_tile_id = TileDataManager.instance.land_tiles[current_tile_index - 1];
	setup(next_tile_id);
