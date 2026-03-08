extends Node2D
class_name MainInputManager

@export_group("Hold input variables")
@export var progress_bar : TextureProgressBar;
@export var hold_input_minimum_duration : float;
@export var hold_input_required_duration : float;
var hold_input : bool = false;
var hold_input_time : float = 0;

var current_number_keycode: int;
var keys_to_index = {
	KEY_1: 0,
	KEY_AMPERSAND : 0,
	KEY_2: 1,
	KEY_ASCIITILDE : 1,
	201 : 1,
	KEY_3: 2,
	KEY_NUMBERSIGN : 2,
	KEY_QUOTEDBL : 2,
	KEY_4: 3,
	KEY_APOSTROPHE : 3,
	KEY_5: 4,
	KEY_BRACELEFT :4
}

# There are two playing mode: 2 clicks and number key + click
# Save the initial click position if not already in click mode
func _input(event: InputEvent) -> void:
	if event.is_action_released('pause-game'):
		GameUI.instance.toggle_pause_window();
	
	if UserSettings.are_input_blocked : return;

	if event.is_action_released('left-click'):
		ClickManager.on_left_click();

	if event is InputEventKey and event.is_action_pressed('select-card-numbers'):
		CardSlotSelector.instance.on_card_slot_selection_via_key(keys_to_index[event.physical_keycode]);

	if event.is_action_released('right-click'):
		CardSlotSelector.instance.unselect_card_slot();
	
	if event.is_action_pressed('debug-generate-card'):
		TileCardFactory.instance.draw_random_card();
		
	if event.is_action_pressed('debug-next-phase'):
		GameLoop.start_phase(GameLoop.get_next_phase());
