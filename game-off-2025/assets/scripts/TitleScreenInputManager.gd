extends Node


func _input(event: InputEvent) -> void:
	if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
