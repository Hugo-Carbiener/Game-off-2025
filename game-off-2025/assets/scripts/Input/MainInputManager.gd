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

func _process(delta: float) -> void:
	if hold_input:
		update_hold_input(delta);

# There are two playing mode: 2 clicks and number key + click
# Save the initial click position if not already in click mode
func _input(event: InputEvent) -> void:
	if event.is_action_released('pause-game'):
		GameUI.instance.toggle_pause_window();
	
	if UserSettings.areInputBlocked : return;
	
	if event.is_action_released('test'):
		SceneLoader.switch_scene_with_transition(SceneLoader.tile_codex_scene, Vector2i.LEFT);
	
	if event.is_action_pressed('left-click'):
		if input_is_held() and !hold_input:
			hold_input = true;

	if event.is_action_released('left-click'):
		ClickManager.on_left_click();
		reset_hold_input();

	if event is InputEventKey and event.is_action_pressed('select-card-numbers'):
		CardSlotSelector.instance.on_card_slot_selection_via_key(keys_to_index[event.physical_keycode]);

	if event.is_action_released('right-click'):
		CardSlotSelector.instance.unselect_card_slot();
	
	if event.is_action_pressed('debug-generate-card'):
		TileCardFactory.instance.draw_random_card();
		
	if event.is_action_pressed('debug-next-phase'):
		GameLoop.start_phase(GameLoop.get_next_phase());

func input_is_held() -> bool:
	return CardSlotSelector.instance.card_is_hovered();

func update_hold_input(delta : float):
	hold_input_time += delta;
	progress_bar.value = hold_input_time * progress_bar.max_value / hold_input_required_duration;
	progress_bar.global_position = progress_bar.get_global_mouse_position() - progress_bar.size/2;
	if hold_input_time > hold_input_minimum_duration and !progress_bar.visible:
		progress_bar.visible = true;
	
	if hold_input_time >= hold_input_required_duration:
		GameUI.instance.toggle_card_codex();
		hold_input = false;

func reset_hold_input():
	progress_bar.visible = false;
	hold_input = false;
	hold_input_time = 0;
