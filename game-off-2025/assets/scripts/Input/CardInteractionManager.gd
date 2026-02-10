extends Node2D
class_name CardInteractionManager

var cursor_preview : Control; ## the control we create to visually move around while dragging
var cursor_preview_anchor_offset : Vector2;

func _process(_delta: float) -> void:
	if card_is_selected():
		cursor_preview.global_position = get_conditionnal_snapped_tile_position();

func card_is_selected() -> bool:
	return false;

func get_snapped_tile_position(local_position : Vector2) -> Vector2:
	# Add an offset so the mouse is on the card sprite
	var card_position = local_position - cursor_preview_anchor_offset;
	# switch to tilemap coords then world coords to snap, add half a tile length horizontally to center it 
	var snaped_card_position = MainTilemap.instance.map_to_local(MainTilemap.instance.local_to_map(card_position)) - Vector2(TileDataManager.tile_size / 2) - Vector2(TileDataManager.tile_size / 2) * Vector2.LEFT;
	return snaped_card_position;

func get_conditionnal_snapped_tile_position() -> Vector2:
	# Add an offset so the mouse is on the card sprite
	var preview_position = get_local_mouse_position() - cursor_preview.size / 2;
	var tilemap_offset = get_viewport().get_visible_rect().size * Constants.tilemap_offset;
	var tilemap_card_position = MainTilemap.instance.local_to_map(get_local_mouse_position() - tilemap_offset);
	if MainTilemap.instance.is_valid_cell(tilemap_card_position):
		var snaped_card_position = MainTilemap.instance.map_to_local(tilemap_card_position) + tilemap_offset - TileDataManager.tile_size / 2.;
		return snaped_card_position;
	else:
		return preview_position;
