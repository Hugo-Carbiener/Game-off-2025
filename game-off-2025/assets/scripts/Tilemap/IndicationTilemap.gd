extends TilemapManager
class_name IndicationTilemap

static var instance : IndicationTilemap;
static var VALID_CELL_TILE_KEY = "valid-cell";
static var RANGE_TILE_KEY = "range-indicator";
static var BREACH_TILE_KEY = "small-breach";

var is_tile_range_displayed = false;
var is_valid_tile_displayed = false;
var last_tile_hovered : Vector2i = Vector2i.ZERO;
var next_breach_position;

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
	# Tile selection
	SignalBus.tile_unselected.connect(on_tile_unselected);

func display_selected_tile_indications(selected_tile : Vector2i):
	clear_tilemap();
	place_tile(selected_tile, TileDataManager.tile_dictionnary[VALID_CELL_TILE_KEY]);
	if MainTilemap.instance.tiles.has(selected_tile):
		display_tile_range(selected_tile);
		return;
	
	if MonsterFactory.monsters.has(selected_tile):
		display_monster_trajectory(selected_tile);
		return;
	
	if MonsterFactory.breaches.has(selected_tile):
		display_breach_targetted_tiles(selected_tile);
		return;

func on_tile_unselected(_tile_uneselected : Vector2i):
	clear_tilemap();

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
	clear_tile(last_tile_hovered);
	if TileSelector.instance.has_selected_tile():
		display_selected_tile_indications(TileSelector.instance.selected_tile);
		
	if cell_distance(new_hovered_tile, Vector2.ZERO) > Constants.beacon_range: return;
	
	place_tile(new_hovered_tile, TileDataManager.tile_dictionnary[VALID_CELL_TILE_KEY]);
	last_tile_hovered = new_hovered_tile;

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

func display_monster_trajectory(cell: Vector2i):
	var monster = MonsterFactory.monsters[cell];
	if monster == null: return;
	
	for trajectory_point in monster.trajectory:
		place_tile(trajectory_point, TileDataManager.tile_dictionnary.get(Constants.TILE_DICT_MONSTER_PATH_KEY));

func display_breach_targetted_tiles(cell: Vector2i):
	var breach = MonsterFactory.breaches[cell]
	if breach == null: return;
	
	for targetted_cell in breach.weak_points:
		place_tile(targetted_cell, TileDataManager.tile_dictionnary.get(RANGE_TILE_KEY));

func display_next_breach():
	next_breach_position = MonsterFactory.instance.next_breach_position;
	place_tile(next_breach_position, TileDataManager.tile_dictionnary.get(BREACH_TILE_KEY), true);
	
	for x in range(-1, 2, 1):
		for y in range(-1, 2, 1):
			var coordinates = Vector2i(x, y);
			if coordinates == Vector2i.ZERO: continue;
			
			place_tile(coordinates + next_breach_position, TileDataManager.tile_dictionnary.get(RANGE_TILE_KEY), true);

func clear_next_breach():
	for x in range(-1, 2, 1):
		for y in range(-1, 2, 1):
			var coordinates = Vector2i(x, y);
			clear_tile(coordinates + next_breach_position);
