extends Control
class_name GameUI

static var instance : GameUI;
@export_group("Card slot UI")
@export var footer_container : MarginContainer;
@export var default_card_slot_modulate : Color;
@export var disabled_card_slot_modulate : Color;
@export_group("Transitions")
@export var card_slot_transition_duration : float;
var card_slot_disabled : bool = true;
@export_group("Components")
@export var phase_title: PhaseTitle;
@export var death_screen : Control;
@export var win_screen : Control;
@export var pause_window : PauseWindow;

func _ready() -> void:
	if instance == null:
		instance = self;
	SignalBus.game_won.connect(on_game_won);
	SignalBus.game_lost.connect(on_game_lost);

func on_game_lost():
	death_screen.visible = true;

func on_game_won():
	win_screen.visible = true;

func toggle_card_slots():
	if card_slot_disabled:
		await transition_card_slot(!card_slot_disabled, default_card_slot_modulate);
	else:
		await transition_card_slot(!card_slot_disabled, disabled_card_slot_modulate);

func transition_card_slot(to : bool, color : Color):
	var tween = get_tree().create_tween();
	tween.set_parallel(true);
	tween.tween_property(footer_container, "modulate", color, card_slot_transition_duration).set_ease(Tween.EASE_IN);
	tween.tween_callback(func(): card_slot_disabled = to);
	await tween.finished;

func update_card_slot_position(margin : int):
	footer_container.add_theme_constant_override("margin_bottom", margin);

func toggle_pause_window():
	pause_window.visible = !pause_window.visible;
	UserSettings.are_input_blocked = pause_window.visible;

func display_phase_title(phase : GameLoop.PHASES):
	await phase_title.launch(phase);
