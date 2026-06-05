class_name TileSelector extends Node2D

static var instance : TileSelector;

var selected_tile : Vector2i;

func _ready() -> void:
	if instance == null:
		instance = self;

func on_tile_selection_interaction():
	var hovered_cell_coordinates = MainTilemap.instance.local_to_map(MainTilemap.instance.get_local_mouse_position());
	if !is_tile_occupied(hovered_cell_coordinates) or hovered_cell_coordinates == selected_tile:
		unselect_tile();
	else: 
		select_tile(hovered_cell_coordinates);

func select_tile(_selected_tile : Vector2i):
	selected_tile = _selected_tile
	await MainCamera.zoom_transition(MainTilemap.instance.map_to_local(selected_tile) + MainTilemap.instance.global_position, Vector2i.ONE * 2);
	SignalBus.tile_selected.emit(selected_tile);

func unselect_tile():
	selected_tile = Vector2i.ZERO;
	await MainCamera.zoom_transition(Vector2i.ZERO, Vector2i.ONE);
	SignalBus.tile_unselected.emit();

func is_tile_occupied(coordinates : Vector2i) -> bool:
	return MainTilemap.instance.tiles.has(coordinates) \
		or MonsterFactory.monsters.has(coordinates) \
		or MonsterFactory.breaches.has(coordinates);

func has_selected_tile() -> bool:
	return selected_tile != Vector2i.ZERO;
