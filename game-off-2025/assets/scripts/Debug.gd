class_name Debug extends Node2D

static var instance : Debug;

@export var scene_to_load : SceneLoader.SCENES;

func _ready() -> void:
	if instance == null:
		instance = self;
	
	if !OS.is_debug_build():
		scene_to_load = SceneLoader.SCENES.TITLESCREEN;
