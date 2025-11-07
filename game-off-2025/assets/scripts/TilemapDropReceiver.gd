extends DropReceiver
class_name TilemapDropReceiver

@onready var tilemap_manager = $"../../../Tilemap manager"

func on_drop(control_dropped : Control):
	## place corresponding tile in the tilemap
	if control_dropped is TileCard :
		tilemap_manager.place_tile(get_local_mouse_position(), control_dropped.card_tile_sprite_atlas_coordinates);
	DragAndDropHandler.destroy_movable_copy();
	control_dropped.queue_free();
