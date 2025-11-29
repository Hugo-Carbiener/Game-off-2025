extends CanvasLayer
class_name UIUtils

static var instance : UIUtils;
@export_group("Card slot UI")
@export var footer_container : MarginContainer;
@export var default_card_slot_modulate : Color;
@export var disabled_card_slot_modulate : Color;
@export var default_card_slot_margin : int;
@export var disabled_card_slot_margin : int;
@export_group("Transitions")
@export var card_slot_transition_duration : float;
var card_slot_disabled : bool = true;
@export_group("UI")
@export var death_screen : Control;
@export var win_screen : Control;
@export var pause_window : PauseWindow;
@export var evolution_window : EvolutionWindow;
@export var main_menu_scene_path : String = "res://scenes/TitleScreen.tscn";
@export_group("UI buttons")
@export var main_menu_buttons : Array[TextureButton];
@export var quit_buttons : Array[TextureButton];

func _ready() -> void:
	if instance == null:
		instance = self;
	init_button_actions();
	SignalBus.game_won.connect(on_game_won);
	SignalBus.game_lost.connect(on_game_lost);

func init_button_actions():
	for button in main_menu_buttons:
		button.button_up.connect(main_menu);
	for button in quit_buttons:
		button.button_up.connect(quit_game);

func on_game_lost():
	death_screen.visible = true

func on_game_won():
	win_screen.visible = true

func main_menu():
	get_tree().change_scene_to_file(main_menu_scene_path);

func quit_game():
	get_tree().quit();

func toggle_card_slots():
	if card_slot_disabled:
		await transition_card_slot(!card_slot_disabled, default_card_slot_modulate, default_card_slot_margin);
	else:
		await transition_card_slot(!card_slot_disabled, disabled_card_slot_modulate, disabled_card_slot_margin);

func transition_card_slot(to : bool, color : Color, to_margin : int):
	var from_margin = footer_container.get_theme_constant("margin_bottom");
	var tween = get_tree().create_tween();
	tween.set_parallel(true);
	tween.tween_property(footer_container, "modulate", color, card_slot_transition_duration).set_ease(Tween.EASE_IN);
	tween.tween_method(update_card_slot_position, from_margin, to_margin, card_slot_transition_duration).set_ease(Tween.EASE_IN);
	tween.tween_callback(func(): card_slot_disabled = to);
	await tween.finished;
	return;

func update_card_slot_position(margin : int):
	footer_container.add_theme_constant_override("margin_bottom", margin);

func on_evolution_discovered(tile_data : CustomTileData):
	evolution_window.setup(tile_data);
	evolution_window.visible = true;

func toggle_pause_window():
	pause_window.visible = !pause_window.visible;
