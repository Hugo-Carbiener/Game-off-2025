class_name NotificationCenter extends Control

static var instance : NotificationCenter;

@export var notification_container : VBoxContainer;

func _ready() -> void:
	if instance == null:
		instance = self;

func notify_new_tile(tile_data : CustomTileData):
	var _notification = Notification.create_notification() \
	.with_atlas_icon(tile_data) \
	.with_text("New tile discovered") \
	.with_button(load_scene.bind(SceneLoader.SCENES.CODEX_SUMMARY));
	notification_container.add_child(_notification);

func load_scene(target_scene_key : SceneLoader.SCENES):
	var scene_data = SceneLoader.scene_data[SceneLoader.current_scene_key];
	var direction = scene_data.scene_buttons_targets.find_key(target_scene_key);
	if direction == null: return;
	
	SceneButtonManager.instance.on_click(target_scene_key, direction);
