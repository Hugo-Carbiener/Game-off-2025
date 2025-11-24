extends Node

func wait(seconds: int):
	await get_tree().create_timer(seconds).timeout
