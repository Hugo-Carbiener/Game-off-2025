extends Node2D

var interaction_areas : Array[InteractionArea]; ## list of control able to receive the drop

func _ready() -> void:
	SignalBus.on_scene_loaded.connect(on_scene_loaded);

func on_scene_loaded(_scene_key : SceneLoader.SCENES):
	init_interaction_areas();

func init_interaction_areas():
	var nodes : Array;
	interaction_areas.clear();
	find_interaction_areas(get_tree().get_root(), nodes);
	for node in nodes :
		if !node.visible: continue;
		
		interaction_areas.append(node);

func find_interaction_areas(node: Node, result : Array) -> void:
	if node is InteractionArea :
		result.append(node);
	for child in node.get_children():
		find_interaction_areas(child, result);

func on_left_click():
	var interaction_area = get_interaction_area_on_cursor();
	if interaction_area == null:
		execute_default_action();
		return;
	
	await interaction_area.interact();

func get_interaction_area_on_cursor() -> InteractionArea:
	for interaction_area in interaction_areas:
		if interaction_area.get_global_rect().has_point(get_local_mouse_position()) :
			return interaction_area;
	return null;

func execute_default_action():
	var default_interaction_area = InteractionArea.new();
	default_interaction_area.interact();
