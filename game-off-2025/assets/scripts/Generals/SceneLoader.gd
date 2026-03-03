extends Node2D

var root : Node2D;
var current_scene_key : SCENES;
var current_scene : Node;
var previous_scene : Node;
var tile_codex_scene : PackedScene = preload("res://scenes/Tile codex/TileCodex.tscn");
var game_scene : PackedScene = preload("res://scenes/game.tscn");

enum SCENES {
	CODEX_SUMMARY,
	GAME
}

var scene_loaders : Dictionary[SCENES, Callable] = {
	SCENES.CODEX_SUMMARY: load_codex_summary_scene,
	SCENES.GAME: load_game_scene
}

var scene_data : Dictionary[SCENES, SceneData] = {
	SCENES.CODEX_SUMMARY: preload("res://assets/resources/sceneData/CodexSceneData.tres"),
	SCENES.GAME: preload("res://assets/resources/sceneData/GameSceneData.tres")
}

func _ready() -> void:
	get_tree().current_scene.ready.connect(init_first_scene);

func init_first_scene():
	root = get_node("/root/Main scene");
	current_scene = load_game_scene();

func switch_scene_with_transition(added_scene : CanvasItem, direction : Vector2i):
	UserData.auto_save()
	var offset = get_viewport_rect().size * Vector2(direction);
	added_scene.position += offset;
	await scene_transition(offset);
	remove_previous_scene_from_tree();
	added_scene.position -= offset;
	MainCamera.get_camera().position -= offset;

func scene_transition(offset : Vector2):
	var tween = get_tree().create_tween();
	tween.tween_property(MainCamera.get_camera(), "position", offset, Constants.scene_transition_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT);
	await tween.finished;
	return

func add_scene_to_tree(scene_key : SCENES, scene : CanvasItem) -> CanvasItem:
	previous_scene = current_scene;
	current_scene = scene;
	current_scene_key = scene_key;
	root.add_child(scene);
	SignalBus.on_scene_loaded.emit(scene_key);
	return scene;

func remove_previous_scene_from_tree():
	previous_scene.queue_free();

## Scene specific accesses

func load_game_scene() -> CanvasItem:
	return add_scene_to_tree(SCENES.GAME, game_scene.instantiate());

func load_codex_summary_scene() -> CanvasItem:
	return add_scene_to_tree(SCENES.CODEX_SUMMARY, TileCodex.load_codex());

func load_codex_scene_at_page(tile_id : String) -> CanvasItem:
	return add_scene_to_tree(SCENES.CODEX_SUMMARY, TileCodex.load_codex_at_page(tile_id));
