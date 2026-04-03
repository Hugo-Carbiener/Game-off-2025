extends Control
class_name GameUI

static var instance : GameUI;
@export_group("Card UI")
@export var footer_container : MarginContainer;
@export_group("Transitions")
@export var card_hand_transition_duration : float;
var card_hand_disabled : bool = true;
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

func update_card_hand_position(margin : int):
	footer_container.add_theme_constant_override("margin_bottom", margin);

func toggle_pause_window():
	pause_window.visible = !pause_window.visible;
	UserSettings.are_input_blocked = pause_window.visible;

func display_phase_title(phase : GameLoop.PHASES):
	await phase_title.launch(phase);
