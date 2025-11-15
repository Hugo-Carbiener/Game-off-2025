extends Node2D 

const DUPLICATE_STRUCTURE_ONLY = 0  # no signals, no scripts, no groups

var is_dragging = false;
var dragged_control : Control; ## the control currently being dragged
var control_copy : Control; ## the control we create to visually move around while dragging
var drop_receivers : Array[DropReceiver]; ## list of control able to receive the drop
var transition_duration = 0.5;
var tile_preview : Control;

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
		var dragged_control_offset = Vector2(tile_preview.size.x/2, tile_preview.position.y + tile_preview.size.y/2);
		var dragged_control_position = get_local_mouse_position() - dragged_control_offset;
		var snaped_control_position = MainTilemap.instance.map_to_local(MainTilemap.instance.local_to_map(dragged_control_position)) + Vector2.ONE + Vector2.DOWN;
		control_copy.position = snaped_control_position;

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
	is_dragging = true;
	create_movable_copy(dragged_control);
	dragged_control.visible = false;

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
	control_copy = control_to_copy.duplicate();	
	control_copy.position = get_local_mouse_position();
	tile_preview = control_copy.card_sprite;
	get_tree().current_scene.add_child(control_copy);
	
	on_drag_transition(control_copy, control_copy.card_name, control_copy.card_description, control_copy.card_sprite);
	control_copy.set_script(null);

func destroy_movable_copy(): 
	control_copy.queue_free();

func on_drag_transition(card_bg : Control, card_name : Control, card_desc : Control, _tile_preview : Control):
	var tween = get_tree().create_tween();
	tween.set_parallel();
	tween.tween_property(card_bg, "self_modulate", Color(1.0,1.0,1.0,0), transition_duration);
	tween.tween_property(card_name, "self_modulate", Color(1.0,1.0,1.0,0), transition_duration);
	tween.tween_property(card_desc, "self_modulate", Color(1.0,1.0,1.0,0), transition_duration);
	await tween.finished;
