extends Node2D
class_name InputManager

var card_selected: bool = false;
var current_number_keycode: int;
var keys_to_index = {
	49: 0,
	50: 1,
	51: 2,
	52: 3,
	53: 4
}

# There are two playing mode: 2 clicks and number key + click

# Save the initial click position if not already in click mode
func _input(event: InputEvent) -> void:
	if event.is_action_released('select-card-mouse'):
		if card_selected:
			card_selected = false;
			DragAndDropHandler.instance.on_drop_input();
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
	
	if event.is_action_pressed('generate-card'):
		TileCardFactory.instance.draw_random_card();
		
	if event.is_action_pressed('next-phase'):
		GameLoop.start_phase(GameLoop.get_next_phase());

func start_selection(event: InputEvent):
	var init_drag = DragAndDropHandler.instance.on_drag_card_at_slot(keys_to_index[event.keycode]);
			
	if init_drag:
		current_number_keycode = event.keycode;
		card_selected = true;
