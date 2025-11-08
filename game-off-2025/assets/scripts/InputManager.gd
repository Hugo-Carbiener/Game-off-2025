extends Node2D
class_name InputManager

static var GENERATE_CARD_ACTION_KEY = "generate-card";
static var DRAG_AND_DROP_ACTION_KEY = "drag-and-drop";
static var NEXT_PHASE_ACTION_KEY = "next-phase";

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(GENERATE_CARD_ACTION_KEY):
		TileCardFactory.instance.generate_random_card();

	if Input.is_action_just_pressed(DRAG_AND_DROP_ACTION_KEY):
		DragAndDropHandler.on_drag_input();
		
	if Input.is_action_just_released(DRAG_AND_DROP_ACTION_KEY):
		DragAndDropHandler.on_drop_input();
		
	if Input.is_action_just_pressed(NEXT_PHASE_ACTION_KEY):
		GameLoop.start_phase(GameLoop.get_next_phase());
