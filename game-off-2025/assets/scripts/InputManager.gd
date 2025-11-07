extends Node2D
class_name InputManager

@onready var tilemap_manager = $"../Main tilemap"

static var PLACE_TILE_ACTION_KEY = "place-tile";
static var REMOVE_TILE_ACTION_KEY = "remove-tile";
static var GENERATE_CARD_ACTION_KEY = "generate-card";
static var DRAG_AND_DROP_ACTION_KEY = "drag-and-drop";

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(PLACE_TILE_ACTION_KEY):
		tilemap_manager.place_tile(get_global_mouse_position(), tilemap_manager.TILES.RIVER);

	if Input.is_action_just_pressed(REMOVE_TILE_ACTION_KEY):
		tilemap_manager.place_tile(get_global_mouse_position(), tilemap_manager.TILES.EMPTY);

	if Input.is_action_just_pressed(GENERATE_CARD_ACTION_KEY):
		TileCardFactory.instance.generate_random_card();

	if Input.is_action_just_pressed(DRAG_AND_DROP_ACTION_KEY):
		DragAndDropHandler.on_drag_input();
		
	if Input.is_action_just_released(DRAG_AND_DROP_ACTION_KEY):
		DragAndDropHandler.on_drop_input();
