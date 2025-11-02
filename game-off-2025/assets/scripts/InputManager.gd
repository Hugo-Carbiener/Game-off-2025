extends Node2D
class_name InputManager

@onready var tilemap_manager = $"../Tilemap manager"

static var PLACE_TILE_ACTION_KEY = "place-tile";
static var REMOVE_TILE_ACTION_KEY = "remove-tile";
static var GENERATE_CARD_ACTION_KEY = "generate-card";

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(PLACE_TILE_ACTION_KEY) :
		tilemap_manager.place_tile(get_global_mouse_position(), tilemap_manager.TILES.RIVER);

	if Input.is_action_just_pressed(REMOVE_TILE_ACTION_KEY) :
		tilemap_manager.place_tile(get_global_mouse_position(), tilemap_manager.TILES.EMPTY);

	if Input.is_action_just_pressed(GENERATE_CARD_ACTION_KEY) :
		TileCardFactory.instance.instantiate_random_card();
