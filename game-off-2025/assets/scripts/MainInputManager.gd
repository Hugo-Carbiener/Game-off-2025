extends Node2D
class_name MainInputManager

var card_selected: bool = false;
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
	if UserSettings.areInputBlocked : return;
	
	if event.is_action_released('select-card-mouse'):
		if card_selected:
			var shouldContinue = DragAndDropHandler.instance.on_drop_input();
			
			# allow multiple consecutive placements of same card
			if !shouldContinue:
				card_selected = false;
				
		else:
			var init_drag = DragAndDropHandler.instance.on_drag_input();
			if init_drag:
				card_selected = true;
		
	if event is InputEventKey and event.is_action_pressed('select-card-numbers'):
		if card_selected:
			DragAndDropHandler.instance.cancel_drag();
				
			# pressing the same key cancel the drag
			if current_number_keycode == event.keycode:
				card_selected = false;
			# during drag, pressing a different key select another card
			else: 
				start_selection(event);
		else:
			start_selection(event);
			
	if event.is_action_released('select-card-mouse-cancel'):
			card_selected = false;
			DragAndDropHandler.instance.cancel_drag();

	if event.is_action_released('pause-game'):
		UIUtils.instance.toggle_pause_window();
	
	if event.is_action_pressed('debug-generate-card'):
		TileCardFactory.instance.draw_random_card();
		
	if event.is_action_pressed('debug-next-phase'):
		GameLoop.start_phase(GameLoop.get_next_phase());
	

func start_selection(event: InputEventKey):
	if UserSettings.areInputBlocked: return;
	var init_drag = DragAndDropHandler.instance.on_drag_card_at_slot(keys_to_index[event.physical_keycode]);
			
	if init_drag:
		current_number_keycode = event.keycode;
		card_selected = true;
