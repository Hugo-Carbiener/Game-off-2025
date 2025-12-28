extends CardInteractionManager 
class_name DragAndDropHandler

const DUPLICATE_STRUCTURE_ONLY = 0  # no signals, no scripts, no groups

static var instance : DragAndDropHandler;

var is_dragging = false;
var dragged_control : Control; ## the control currently being dragged
var transition_duration = 0.5;	

func _ready() -> void:
	super();
	if instance == null:
		instance = self;

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
	var interaction_area = get_interaction_area_on_cursor();
	if interaction_area == null:
		cancel_drag();
		return false;
	return interaction_area.on_iteraction(dragged_control);

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

func create_movable_copy(control_to_copy: Control):
	cursor_preview = control_to_copy.duplicate();
	cursor_preview_anchor_offset = Vector2(control_to_copy.card_sprite.size.x/2, control_to_copy.card_sprite.global_position.y - control_to_copy.global_position.y );
	cursor_preview.position = get_local_mouse_position() - cursor_preview_anchor_offset;
	get_tree().current_scene.add_child(cursor_preview);
	on_drag_transition();

func destroy_movable_copy():
	if cursor_preview:
		cursor_preview.queue_free();

func on_drag_transition():
	var tween = get_tree().create_tween();
	tween.set_parallel();
	
	# hide card count instantly
	cursor_preview.card_count_overlay.self_modulate = Color(1.0,1.0,1.0,0);
	cursor_preview.card_count.self_modulate = Color(1.0,1.0,1.0,0);
	# progressively hide the rest
	tween.tween_property(cursor_preview, "self_modulate", Color(1.0,1.0,1.0,0), transition_duration);
	tween.tween_property(cursor_preview.card_overlay, "self_modulate", Color(1.0,1.0,1.0,0), transition_duration);
	tween.tween_property(cursor_preview.card_name, "self_modulate", Color(1.0,1.0,1.0,0), transition_duration);
	tween.tween_property(cursor_preview.card_description, "self_modulate", Color(1.0,1.0,1.0,0), transition_duration);
	tween.tween_property(cursor_preview.card_icons, "modulate", Color(1.0,1.0,1.0,0), transition_duration);
	tween.tween_property(cursor_preview.card_evolution_title, "modulate", Color(1.0,1.0,1.0,0), transition_duration);
	tween.tween_property(cursor_preview.card_evolutions, "modulate", Color(1.0,1.0,1.0,0), transition_duration);
	await tween.finished;
