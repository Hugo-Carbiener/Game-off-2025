extends Control
class_name TileCard

const tile_card_scene: PackedScene = preload("res://scenes/components/TileCard.tscn");

var card_id : String;
var card_color : Color;
var is_draggable : bool;
@export_group("Components")
@export var card_chains : TextureRect;
@export var card_overlay : TextureRect;
@export var card_border : TextureRect;
@export var card_name : Label;
@export var card_sprite : TextureRect;
@export var card_mouse_detector : TileCardMouseDetector;
@export var card_effects_icons : HBoxContainer;
@export var card_description : Label;
@export var card_evolution_title : Label;
@export var tile_card_evolution_container : GridContainer;
@export var card_damage_label : Label;
@export var card_damage_icon : TextureRect;
@export var card_range_label : Label;
@export var card_range_icon : TextureRect;
@export_group("Variables")
@export var card_hover_bottom_offset : int;
@export var card_selection_bottom_offset : int;
@export var card_side_offset : int;
@export var selectiony_transition_duration : float;
@export var card_movement_transition_duration : float;

var tile_card_evolutions : Array[TileCardEvolution];
var card_tile_sprite_atlas_coordinates : Vector2i;

static func create_tile_card(id : String, draggable : bool = true) -> TileCard:
	var tile_card = tile_card_scene.instantiate();
	tile_card.setup(id, draggable);
	return tile_card;

func with_clickable_evolutions(on_evolution_click : Callable) -> TileCard:
	init_evolutions_click(on_evolution_click);
	return self;

func setup(_id : String, draggable : bool) :
	var tile_data = TileDataManager.tile_dictionnary[_id] if UserData.get_known_tiles().has(_id) else TileDataManager.tile_dictionnary["unknown"] ;
	is_draggable = draggable;
	set_meta('Draggable', is_draggable);
	pivot_offset = size / 2;
	card_id = _id;
	card_name.text = tile_data.name;
	card_description.text = tile_data.description;
	card_damage_label.text = str(tile_data.damage);
	card_range_label.text = tile_data.effect_range.range_to_string();
	card_sprite.texture.region = tile_data.get_texture_region();
	card_border.visible = false;
	card_chains.visible = !UserData.get_known_tiles().has(_id);
	init_signals();
	init_icons(tile_data);
	init_evolutions(tile_data);
	init_color(tile_data.color);

func reset():
	for card_effects_icon in card_effects_icons.get_children():
		card_effects_icon.queue_free();
	for tile_card_evolution in tile_card_evolutions:
		tile_card_evolution.queue_free();
	tile_card_evolutions.clear();

	if card_mouse_detector.mouse_entered.is_connected(on_mouse_entered):
		card_mouse_detector.mouse_entered.disconnect(on_mouse_entered);
	if mouse_exited.is_connected(on_mouse_exit):
		mouse_exited.disconnect(on_mouse_exit);

func init_signals():
	card_mouse_detector.mouse_entered.connect(on_mouse_entered);
	card_mouse_detector.mouse_exited.connect(on_mouse_exit);

func init_color(color : Color) :
	card_color = color;
	card_name.label_settings = card_name.label_settings.duplicate();
	card_name.label_settings.font_color = color;
	card_description.label_settings = card_description.label_settings.duplicate();
	card_description.label_settings.font_color = color;
	card_damage_label.label_settings = card_damage_label.label_settings.duplicate();
	card_damage_label.label_settings.font_color = color;
	card_range_label.label_settings = card_range_label.label_settings.duplicate();
	card_range_label.label_settings.font_color = color;

	card_overlay.modulate = color;
	card_chains.modulate = color;
	card_border.modulate = color;
	card_damage_icon.modulate = color;
	card_range_icon.modulate = color;
	for card_effects_icon in card_effects_icons.get_children():
		card_effects_icon.modulate = color;
	
	card_evolution_title.label_settings = card_evolution_title.label_settings.duplicate();
	card_evolution_title.label_settings.font_color = color;
	for tile_card_evolution in tile_card_evolutions:
		tile_card_evolution.init_color(color);

func init_icons(tile_data : CustomTileData) :
	if !tile_data.effects.is_empty():
		for effect in tile_data.effects:
			var icon = TextureRect.new();
			icon.texture = effect.icon;
			card_effects_icons.add_child(icon);

func init_evolutions(tile_data : CustomTileData):
	if tile_data.evolutions == null or tile_data.evolutions.is_empty() : 
		card_evolution_title.visible = false;
		return;
	for evolution in tile_data.evolutions:
		var evolution_tile_data = TileDataManager.tile_dictionnary[evolution];
		if evolution_tile_data == null: return;
		
		var tile_card_evolution = TileCardEvolution.create_tile_card_evolution(evolution_tile_data);
		tile_card_evolutions.append(tile_card_evolution);
		tile_card_evolution_container.add_child(tile_card_evolution);

func init_evolutions_click(on_click : Callable):
	for tile_card_evolution in tile_card_evolutions:
		tile_card_evolution.init_buttons(on_click);

func update_evolutions():
	for tile_card_evolution in tile_card_evolutions:
		tile_card_evolution.update();

# Called before a card is destroyed
func discard():
	SignalBus.card_discarded.emit(self);
	await AnimationUtils.animate_scale(self, scale, Vector2.ZERO, card_movement_transition_duration);
	queue_free();

func on_card_reroll():
	print("Not implemented");
	#if TileCardFactory.instance.reroll_left == 0:
		#return;
		#
	#TileCardFactory.instance.reroll_left -= 1;
	#SignalBus.reroll_amount_updated.emit(TileCardFactory.instance.reroll_left);
	#TileCardFactory.instance.cards_amount[card_id] -= 1;
	#TileCardFactory.instance.cards_amount.total -= 1;
	#
	#if (TileCardFactory.instance.cards_amount[card_id] == 0):
		#TileCardFactory.instance.free_card_slot(card_id);
	#
	#SignalBus.card_discarded.emit(self);
#
	#TileCardFactory.instance.draw_random_card();

func update_card_bottom_margin(bottom_target_margin : int):
	add_theme_constant_override("margin_bottom", bottom_target_margin);

func update_card_side_margins(side_target_margin : int):
	add_theme_constant_override("margin_left", side_target_margin);
	add_theme_constant_override("margin_right", side_target_margin);

func transition_card_margin():
	var tween = get_tree().create_tween();
	tween.set_parallel(true);
	tween.tween_method(update_card_bottom_margin, get_theme_constant("margin_bottom"), get_current_bottom_margin(), selectiony_transition_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT);
	tween.tween_method(update_card_side_margins, get_theme_constant("margin_left"), get_current_side_margin(), selectiony_transition_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT);

func get_current_bottom_margin() -> int:
	if card_is_selected():
		return card_selection_bottom_offset;
	if card_is_hovered():
		return card_hover_bottom_offset;
	return 0;

func get_current_side_margin() -> int:
	if card_is_selected() or card_is_hovered():
		return card_side_offset;
	return 0;

func on_mouse_entered():
	if UserSettings.are_input_blocked or !is_draggable: return;
	if card_is_selected(): return;
	if !TileDataManager.tile_dictionnary[card_id].is_playable: return;
	
	var card_index = TileCardFactory.instance.cards.find(self);
	if card_index == -1: return;
	
	CardSelector.instance.card_index_hovered = card_index;
	transition_card_margin();

func on_mouse_exit():
	if !is_draggable: return;
	if card_is_selected(): return;

	CardSelector.instance.card_index_hovered = -1;
	transition_card_margin();

func on_selection():
	transition_card_margin();
	card_border.visible = true;

func on_unselection():
	transition_card_margin();
	card_border.visible = false;

func card_is_selected() -> bool:
	return CardSelector.instance.get_selected_card() == self;

func card_is_hovered() -> bool:
	return CardSelector.instance.get_hovered_card() == self;
