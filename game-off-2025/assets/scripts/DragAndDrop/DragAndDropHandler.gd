extends Node2D 

const DUPLICATE_STRUCTURE_ONLY = 0  # no signals, no scripts, no groups

var is_dragging = false;
var dragged_control : Control; ## the control currently being dragged
var control_copy : Control; ## the control we create to visually move around while dragging
var dragged_control_offset : Vector2; ## the position offset to hold the control from where the mouse was
var drop_receivers : Array[DropReceiver]; ## list of control able to receive the drop

func _ready() -> void:
	var nodes : Array;
	find_drop_receivers(get_tree().get_root(), nodes);
	for node in nodes :
		drop_receivers.append(node);

func find_drop_receivers(node: Node, result : Array) -> void:
	if node is DropReceiver :
		result.push_back(node);
	for child in node.get_children():
		find_drop_receivers(child, result);

func _process(_delta: float) -> void:
	if is_dragging:
		control_copy.position = get_local_mouse_position();

func on_drag_input():
	if GameLoop.current_phase != GameLoop.PHASES.PLAY: return;
	
	dragged_control = get_control_to_drag();
	if dragged_control == null: return;
	drag();

func on_drop_input():
	if GameLoop.current_phase != GameLoop.PHASES.PLAY: return;

	if !is_dragging: return;
	
	drop();

func drag():
	create_movable_copy(dragged_control);
	dragged_control.visible = false;
	is_dragging = true;

func drop():
	on_drop();
	
	is_dragging = false;

func on_drop():
	var drop_receiver = get_control_to_drop_in();
	if drop_receiver == null:
		cancel_drag();
		return;
	drop_receiver.on_drop(dragged_control);

func cancel_drag() :
	destroy_movable_copy();
	dragged_control.visible = true;
	is_dragging = false;

func get_control_to_drag() -> Control:
	var control_child : Control = get_viewport().gui_get_hovered_control();
	if control_child == null: return;
	
	## we get the root node of the instantiated scene 
	var control = control_child.owner;
	if !control.has_meta("Draggable") || !control.get_meta("Draggable"): return;
		
	return control;

func get_control_to_drop_in() -> DropReceiver:
	for drop_receiver in drop_receivers:
		if drop_receiver.get_global_rect().has_point(get_viewport().get_mouse_position()) :
			return drop_receiver;
	return null;

func create_movable_copy(control_to_copy: Control):
	# use the drag preview if exists, otherwise duplicate the full control
	if "drag_preview" in control_to_copy:
		control_copy = control_to_copy.drag_preview.duplicate(DUPLICATE_STRUCTURE_ONLY);
	else:
		control_copy = control_to_copy.duplicate(DUPLICATE_STRUCTURE_ONLY);
	
	dragged_control_offset = control_to_copy.global_position - get_local_mouse_position();
	control_copy.position = get_local_mouse_position() + dragged_control_offset;
	get_tree().current_scene.add_child(control_copy);

func destroy_movable_copy(): 
	control_copy.queue_free();
