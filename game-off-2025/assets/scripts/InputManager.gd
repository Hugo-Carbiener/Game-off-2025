extends Node2D
class_name InputManager

static var GENERATE_CARD_ACTION_KEY = "generate-card";
static var DRAG_AND_DROP_ACTION_KEY = "drag-and-drop";
static var NEXT_PHASE_ACTION_KEY = "next-phase";

var is_dragging: bool = false;
var is_clicking: bool = false;
var dragging_distance: float;
var initial_pos: Vector2;

# There are two playing mode: drag and drop and 2 clicks

# Save the initial click position if not already in click mode
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action_pressed(DRAG_AND_DROP_ACTION_KEY) and is_clicking == false:
		initial_pos = event.global_position;

func _process(_delta: float) -> void:
	if Input.is_action_pressed(DRAG_AND_DROP_ACTION_KEY):
		# if we are in click mode, and reclick it means we immediately drop
		if is_clicking:
			is_clicking = false;
			DragAndDropHandler.on_drop_input();
			return;
		
		# if we are dragging, we should ignore clicks are we are already clicking (unless something strange happens)
		if is_dragging:
			return;
		
		# get distance between initial click and mouse position (converted to the right coordinates)
		var camera = get_viewport().get_camera_2d();
		var mouse_pos = camera.get_canvas_transform() * get_global_mouse_position();		
		dragging_distance = mouse_pos.distance_to(initial_pos);

		# if distance long enough, consider it a drag and drop
		if dragging_distance > 10:
			is_clicking = false;
			if is_dragging == false:
				is_dragging = true;
				DragAndDropHandler.on_drag_input();
	
	# when release the button we have two cases: 
	# - either it's "immediate" and we will have a small distance -> click mode
	# - either it's during a drag mode and we can then drop
	if Input.is_action_just_released(DRAG_AND_DROP_ACTION_KEY):
		if dragging_distance < 10:
			is_clicking = true;
			DragAndDropHandler.on_drag_input();
		if is_dragging:
			is_dragging = false;
			DragAndDropHandler.on_drop_input();
		
	if Input.is_action_just_pressed(GENERATE_CARD_ACTION_KEY):
		TileCardFactory.instance.draw_random_card();
		
	if Input.is_action_just_pressed(NEXT_PHASE_ACTION_KEY):
		GameLoop.start_phase(GameLoop.get_next_phase());
