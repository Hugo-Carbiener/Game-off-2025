extends Node2D

@onready var tilemap_manager = $"../Tilemap manager";

static var PLACE_TILE_ACTION_KEY = "place-tile";
static var REMOVE_TILE_ACTION_KEY = "remove-tile";

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(PLACE_TILE_ACTION_KEY) :
		tilemap_manager.place_tile(get_global_mouse_position(), tilemap_manager.TILES.RIVER)

	if Input.is_action_just_pressed(REMOVE_TILE_ACTION_KEY) :
		tilemap_manager.place_tile(get_global_mouse_position(), null)
