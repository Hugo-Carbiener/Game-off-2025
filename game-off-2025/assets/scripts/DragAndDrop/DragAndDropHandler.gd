extends Node2D 
class_name DragAndDropHandler

const DUPLICATE_STRUCTURE_ONLY = 0  # no signals, no scripts, no groups

var is_dragging = false;
var dragged_control : Control; ## the control currently being dragged
var drop_receivers : Array[DropReceiver]; ## list of control able to receive the drop
var transition_duration = 0.5;

var control_copy : Control; ## the control we create to visually move around while dragging
var control_copy_anchor_offset : Vector2;

static var instance : DragAndDropHandler;

func _ready() -> void:
	if instance == null:
		instance = self;
		
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
		control_copy.position = get_conditionnal_snapped_tile_position();

func get_snapped_tile_position(local_position : Vector2) -> Vector2:
	# Add an offset so the mouse is on the card sprite
	var card_position = local_position - control_copy_anchor_offset;
	# switch to tilemap coords then world coords to snap, add half a tile length horizontally to center it 
	var snaped_card_position = MainTilemap.instance.map_to_local(MainTilemap.instance.local_to_map(card_position)) - Vector2(TileDataManager.instance.tile_size / 2) - Vector2(TileDataManager.instance.tile_size / 2) * Vector2.LEFT;
	return snaped_card_position;

func get_conditionnal_snapped_tile_position() -> Vector2:
	# Add an offset so the mouse is on the card sprite
	var card_position = get_local_mouse_position() - control_copy_anchor_offset;
	var tilemap_card_position = MainTilemap.instance.local_to_map(MainTilemap.instance.get_local_mouse_position());
	if MainTilemap.instance.is_valid_cell(tilemap_card_position):
		var snaped_card_position = MainTilemap.instance.map_to_local(MainTilemap.instance.local_to_map(card_position)) - Vector2(TileDataManager.instance.tile_size / 2) - Vector2(TileDataManager.instance.tile_size / 2) * Vector2.LEFT;
		return snaped_card_position;
	else :
		return card_position;
	

func on_drag_card_at_slot(index: int): 
	if index < TileCardFactory.instance.card_slot_used_amount:
		on_drag_input(TileCardFactory.instance.card_slots[index].get_children()[2]);
		return true;
	else:
		return false;

func on_drag_input(control: Control = null):
	if GameLoop.current_phase != GameLoop.PHASES.PLAY: return;
	
	if control != null:
		dragged_control = control;
	else:
		dragged_control = get_control_to_drag();

	if dragged_control == null: 
		return false ;
	
	drag();
	return true;

# indicate to the input manager if we can continue dropping items
func on_drop_input() -> bool:
	if GameLoop.current_phase != GameLoop.PHASES.PLAY: return false;

	if !is_dragging: return false;
	
	return on_drop();

func drag():
	is_dragging = true;
	create_movable_copy(dragged_control);

# return value indicate if we can continue dropping or not
func on_drop() -> bool:
	var drop_receiver = get_control_to_drop_in();
	if drop_receiver == null:
		cancel_drag();
		return false;
	return drop_receiver.on_drop(dragged_control);

func cancel_drag() :
	destroy_movable_copy();
	is_dragging = false;

func get_control_to_drag() -> Control:
	var control_child : Control = get_viewport().gui_get_hovered_control();
	if control_child == null: return;
	
	## we get the root node of the instantiated scene 
	var control = control_child.owner;
	if control == null: return;
	var root = control;
	while (!root.has_meta("Draggable") || !root.get_meta("Draggable")) and root != get_tree().root:
		root = root.get_parent();
	
	if root == get_tree().root: return;
	return root;

func get_control_to_drop_in() -> DropReceiver:
	for drop_receiver in drop_receivers:
		if drop_receiver.get_global_rect().has_point(get_viewport().get_mouse_position()) :
			return drop_receiver;
	return null;

func create_movable_copy(control_to_copy: Control):
	control_copy = control_to_copy.duplicate();
	control_copy_anchor_offset = Vector2(control_to_copy.card_sprite.size.x/2, control_to_copy.card_sprite.global_position.y - control_to_copy.global_position.y );
	control_copy.position = get_local_mouse_position() - control_copy_anchor_offset;
	get_tree().current_scene.add_child(control_copy);
	on_drag_transition();

func destroy_movable_copy(): 
	if control_copy:
		control_copy.queue_free();

func on_drag_transition():
	var tween = get_tree().create_tween();
	tween.set_parallel();
	
	# hide card count instantly
	control_copy.card_count_overlay.self_modulate = Color(1.0,1.0,1.0,0);
	control_copy.card_count.self_modulate = Color(1.0,1.0,1.0,0);
	# progressively hide the rest
	tween.tween_property(control_copy, "self_modulate", Color(1.0,1.0,1.0,0), transition_duration);
	tween.tween_property(control_copy.card_overlay, "self_modulate", Color(1.0,1.0,1.0,0), transition_duration);
	tween.tween_property(control_copy.card_name, "self_modulate", Color(1.0,1.0,1.0,0), transition_duration);
	tween.tween_property(control_copy.card_description, "self_modulate", Color(1.0,1.0,1.0,0), transition_duration);
	tween.tween_property(control_copy.card_icons, "modulate", Color(1.0,1.0,1.0,0), transition_duration);
	tween.tween_property(control_copy.card_evolution_title, "modulate", Color(1.0,1.0,1.0,0), transition_duration);
	tween.tween_property(control_copy.card_evolutions, "modulate", Color(1.0,1.0,1.0,0), transition_duration);
	await tween.finished;
