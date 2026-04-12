extends TilemapManager
class_name IndicationTilemap

static var instance : IndicationTilemap;
static var VALID_CELL_TILE_KEY = "valid-cell";
static var RANGE_TILE_KEY = "range-indicator";

var is_monster_path_displayed = false;
var is_tile_range_displayed = false;
var is_valid_tile_displayed = false;
var last_tile_hovered : Vector2i = Vector2i.ZERO;

func _ready() -> void:
	super();
	if instance == null:
		instance = self;
	init_signals();

func init_signals():
	# Valid cells
	SignalBus.card_discarded.connect(update_valid_cells);
	SignalBus.evolution_started.connect(clear_tilemap);
	SignalBus.resolution_phase_started.connect(clear_tilemap);
	# Card selection
	SignalBus.card_selected.connect(display_valid_cells);
	SignalBus.card_unselected.connect(clear_valid_cells);

func display_selected_tile_indications(selected_tile : Vector2i):
	place_tile(selected_tile, TileDataManager.tile_dictionnary[VALID_CELL_TILE_KEY]);
	if MainTilemap.instance.tiles.has(selected_tile):
		display_tile_range(selected_tile);
		return;
	
	if MonsterFactory.monsters.has(selected_tile):
		display_monster_trajectory(selected_tile);
		return;

func on_tile_unselected():
	clear_tilemap();

func display_monster_trajectory(cell: Vector2i):
	var monster = MonsterFactory.instance.monsters.get(cell);
	if monster == null: return;
	
	is_monster_path_displayed = true;
	
	for trajectory_point in monster.trajectory:		
		place_tile(trajectory_point, TileDataManager.tile_dictionnary.get(Constants.TILE_DICT_MONSTER_PATH_KEY));

func _input(event):
	check_for_tile_hover(event);

func check_for_tile_hover(event : InputEvent):
	if event is not InputEventMouseMotion: return;
	
	var cell = local_to_map(get_local_mouse_position());
	if CardSelector.instance.card_is_selected(): 
		return;
		
	if cell != last_tile_hovered: 
		update_hovered_tile(cell);

func update_hovered_tile(new_hovered_tile : Vector2i):
	clear_tilemap();
	if cell_distance(new_hovered_tile, Vector2.ZERO) > Constants.beacon_range: return;
	
	if TileSelector.instance.has_selected_tile():
		display_selected_tile_indications(TileSelector.instance.selected_tile);
	place_tile(new_hovered_tile, TileDataManager.tile_dictionnary[VALID_CELL_TILE_KEY]);

func clear_monster_indications():
	if is_monster_path_displayed:
		clear_tilemap();
		update_valid_cells();
		is_monster_path_displayed = false;

func display_valid_cells():
	if MainTilemap.instance.is_currently_evolving_tile(): return;
	
	is_valid_tile_displayed = true;
	var valid_cells = MainTilemap.instance.get_valid_cells();
	for valid_cell in valid_cells:
		place_tile(valid_cell, TileDataManager.tile_dictionnary[VALID_CELL_TILE_KEY]);

func clear_valid_cells():
	if is_valid_tile_displayed:
		clear_tilemap();
		is_valid_tile_displayed = false;

func update_valid_cells(_tilecard : TileCard = null):
	if CardSelector.instance.card_is_selected():
		if is_valid_tile_displayed:
			clear_tilemap();
			is_valid_tile_displayed = false;
		
		display_valid_cells();

func display_tile_range(cell : Vector2i):
	if !MainTilemap.instance.tiles.has(cell): return; 
	
	var tile = MainTilemap.instance.tiles[cell];
	var offset_coordinates = tile.get_cells_in_range();
	if offset_coordinates.size() <= 1 : return;
	
	is_tile_range_displayed = true;
	for offset_coordinate in offset_coordinates:
		place_tile(cell + offset_coordinate, TileDataManager.tile_dictionnary[RANGE_TILE_KEY]);
