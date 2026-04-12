extends Node2D

var root : Node2D;
var current_scene_key : SCENES;
var current_scene : Node;
var previous_scene : Node;
var title_screen_scene : PackedScene = preload("res://scenes/TitleScreen.tscn");
var tutorial_1_scene : PackedScene = preload("res://scenes/Tutorial_1.tscn");
var tutorial_2_scene : PackedScene = preload("res://scenes/Tutorial_2.tscn");
var tutorial_3_scene : PackedScene = preload("res://scenes/Tutorial_3.tscn");
var tutorial_4_scene : PackedScene = preload("res://scenes/Tutorial_4.tscn");
var tile_codex_scene : PackedScene = preload("res://scenes/tile_codex/TileCodex.tscn");
var game_scene : PackedScene = preload("res://scenes/game.tscn");

var default_game_scene = SCENES.TUTORIAL_1;

enum SCENES {
	TITLESCREEN,
	TUTORIAL_1,
	TUTORIAL_2,
	TUTORIAL_3,
	TUTORIAL_4,
	CODEX_SUMMARY,
	GAME
}

var scenes : Dictionary[SCENES, PackedScene] = {
	SCENES.TITLESCREEN: title_screen_scene,
	SCENES.TUTORIAL_1: tutorial_1_scene,
	SCENES.TUTORIAL_2: tutorial_2_scene,
	SCENES.TUTORIAL_3: tutorial_3_scene,
	SCENES.TUTORIAL_4: tutorial_4_scene,
	SCENES.CODEX_SUMMARY: tile_codex_scene,
	SCENES.GAME: game_scene
}

var scene_data : Dictionary[SCENES, SceneData] = {
	SCENES.CODEX_SUMMARY: preload("res://assets/resources/sceneData/CodexSceneData.tres"),
	SCENES.GAME: preload("res://assets/resources/sceneData/GameSceneData.tres")
}

func _ready() -> void:
	get_tree().current_scene.ready.connect(init_first_scene);

func init_first_scene():
	root = get_node("/root/Main scene");
	load_scene(Debug.instance.scene_to_load);

func load_scene_with_transition(scene_key : SCENES, direction : Vector2i)  -> CanvasItem:
	UserData.auto_save();
	
	var offset = get_viewport_rect().size * Vector2(direction);
	add_scene_to_tree(scene_key);
	current_scene.position += offset;
	
	await scene_transition(offset);
	
	remove_previous_scene_from_tree();
	current_scene.position -= offset;
	MainCamera.get_camera().position -= offset;
	return current_scene;

func load_scene(scene_key : SCENES):
	add_scene_to_tree(scene_key);
	remove_previous_scene_from_tree();

func scene_transition(offset : Vector2):
	var tween = get_tree().create_tween();
	tween.tween_property(MainCamera.get_camera(), "position", offset, Constants.default_transition_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT);
	await tween.finished;
	return

func add_scene_to_tree(scene_key : SCENES) -> CanvasItem:
	if !scenes.has(scene_key):
		printerr("Attempted to load inexistant scene  : " + str(scene_key));
		return;
	
	previous_scene = current_scene;
	current_scene_key = scene_key;
	current_scene = scenes[scene_key].instantiate();
	root.add_child(current_scene);
	SignalBus.on_scene_loaded.emit(scene_key);
	return current_scene;

func remove_previous_scene_from_tree():
	if previous_scene != null:
		UserData.auto_save();
		previous_scene.queue_free();
