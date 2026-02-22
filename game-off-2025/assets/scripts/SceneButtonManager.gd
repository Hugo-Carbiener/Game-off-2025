extends Control
class_name SceneButtonManager

static var instance : SceneButtonManager;

@export_group("Scene buttons")
@export var buttons : Dictionary[Vector2i, TextureButton];
@export var button_icons : Dictionary[Vector2i, TextureRect];

func _ready() -> void:
	if instance == null:
		instance = self;
	SignalBus.on_scene_loaded.connect(init_scene_buttons)

func init_scene_buttons(scene_key : SceneLoader.SCENES):
	reset_scene_buttons();
	var scene_data = SceneLoader.scene_data[scene_key];
	var scene_button_targets = scene_data.scene_buttons_targets;
	var scene_button_icons = scene_data.scene_buttons_icons;
	for direction in buttons.keys():
		var current_scene_button = buttons[direction];
		current_scene_button.visible = scene_button_targets.has(direction) and scene_button_icons.has(direction);
		if current_scene_button.visible:
			var target_scene_key = scene_button_targets[direction];
			current_scene_button.button_up.connect(on_click.bind(target_scene_key, direction));
			button_icons[direction].texture = scene_button_icons[direction];

func reset_scene_buttons():
	for direction in buttons.keys():
		var current_scene_button = buttons[direction];
		for connection in current_scene_button.button_up.get_connections():
			current_scene_button.button_up.disconnect(connection["callable"]);

func on_click(target_scene_key : SceneLoader.SCENES, direction : Vector2i):
	var loader = SceneLoader.scene_loaders[target_scene_key];
	SceneLoader.switch_scene_with_transition(loader.call(), direction);
