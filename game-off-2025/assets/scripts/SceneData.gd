extends Resource
class_name SceneData

@export_group("Scene buttons")
@export var scene_buttons_targets : Dictionary[Vector2i, SceneLoader.SCENES];
@export var scene_buttons_icons : Dictionary[Vector2i, Texture2D];
