extends Node2D

# scenes
var current_scene : Node;
var previous_scene : Node;
var tile_codex_scene : PackedScene = preload("res://scenes/Tile codex/TileCodex.tscn");
var game_scene : PackedScene = preload("res://scenes/game.tscn");

func _ready() -> void:
	get_tree().current_scene.ready.connect(init_first_scene);

func init_first_scene():
	current_scene = get_node("/root/Main scene").get_child(0);

func switch_scene(scene : PackedScene):
	add_scene_to_tree(scene);
	remove_previous_scene_from_tree();

func switch_scene_with_transition(scene : PackedScene, direction : Vector2i):
	var offset = get_viewport_rect().size * Vector2(direction);
	var new_scene = add_scene_to_tree(scene);
	new_scene.position += offset;
	await scene_transition(offset);
	remove_previous_scene_from_tree();
	new_scene.position -= offset;
	MainCamera.get_camera().position -= offset;

func scene_transition(offset : Vector2):
	var tween = get_tree().create_tween();
	tween.tween_property(MainCamera.get_camera(), "position", offset, Constants.scene_transition_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT);
	await tween.finished;
	return

func add_scene_to_tree(scene : PackedScene) -> CanvasItem:
	previous_scene = current_scene;
	var new_scene = scene.instantiate();
	current_scene = new_scene;
	get_tree().root.add_child(new_scene);
	return new_scene;

func remove_previous_scene_from_tree():
	previous_scene.queue_free();
