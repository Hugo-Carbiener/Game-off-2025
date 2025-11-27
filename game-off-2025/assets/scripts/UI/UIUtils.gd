extends CanvasLayer
class_name UIUtils

static var instance : UIUtils;
@export_group("Card slot UI")
@export var card_slot_ui : Control;
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
@export var evolution_window : EvolutionWindow;
@export_group("UI buttons")
@export var quit_buttons : Array[TextureButton];

func _ready() -> void:
	if instance == null:
		instance = self;

func init_button_actions():
	for button in quit_buttons:
		button.button_up.connect(quit_game);

func loose_game():
	death_screen.visible = true

func win_game():
	win_screen.visible = true

func quit_game():
	get_tree().quit();

func toggle_card_slots():
	if card_slot_disabled:
		await transition_card_slot(!card_slot_disabled, default_card_slot_modulate, default_card_slot_margin);
	else:
		await transition_card_slot(!card_slot_disabled, disabled_card_slot_modulate, disabled_card_slot_margin);

func transition_card_slot(to : bool, color : Color, to_margin : int):
	var from_margin = card_slot_ui.get_theme_constant("margin_bottom");
	var tween = get_tree().create_tween();
	tween.set_parallel(true);
	tween.tween_property(card_slot_ui, "modulate", color, card_slot_transition_duration).set_ease(Tween.EASE_IN);
	tween.tween_method(update_card_slot_position, from_margin, to_margin, card_slot_transition_duration).set_ease(Tween.EASE_IN);
	tween.tween_callback(func(): card_slot_disabled = to);
	await tween.finished;
	return;

func update_card_slot_position(margin : int):
	card_slot_ui.add_theme_constant_override("margin_bottom", margin);

func on_evolution_discovered(tile_data : CustomTileData):
	evolution_window.setup(tile_data);
	evolution_window.visible = true;
