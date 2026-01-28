extends TilemapManager
class_name IndicationTilemap

static var instance : IndicationTilemap;
static var VALID_CELL_TILE_KEY = "valid-cell";
static var RANGE_TILE_KEY = "range-indicator";

var is_monster_path_displayed = false;
var is_tile_range_displayed = false;
var is_valid_tile_displayed = false;

func _ready() -> void:
	super();
	if instance == null:
		instance = self;
	init_signals();

func init_signals():
	# Valid cells
	SignalBus.card_used.connect(update_valid_cells);
	SignalBus.evolution_started.connect(clear_tilemap);
	SignalBus.resolution_phase_started.connect(clear_tilemap);
	# Monster paths
	SignalBus.monster_hovered_in.connect(on_monster_hover_in);
	SignalBus.monster_hovered_out.connect(on_monster_hover_out);
	# Tile range
	SignalBus.tile_hovered_in.connect(display_tile_range);
	SignalBus.tile_hovered_out.connect(on_tile_hover_out);
	# Card selection
	SignalBus.card_selected.connect(display_valid_cells);
	SignalBus.card_unselected.connect(clear_valid_cells);

func on_monster_hover_in(cell: Vector2i):
	var monster = MonsterFactory.instance.monsters.get(cell);
	if monster == null: return;
	
	is_monster_path_displayed = true;
	
	for trajectory_point in monster.trajectory:
		place_tile(trajectory_point, TileDataManager.instance.tile_dictionnary.get(Constants.TILE_DICT_MONSTER_PATH_KEY));

func on_monster_hover_out(cell: Vector2i):
	if MonsterFactory.monsters.has(cell):
		clear_monster_indications();

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
		place_tile(valid_cell, TileDataManager.instance.tile_dictionnary[VALID_CELL_TILE_KEY]);

func clear_valid_cells():
	if is_valid_tile_displayed:
		clear_tilemap();
		is_valid_tile_displayed = false;

func update_valid_cells(_card_amount : int = 0):
	if CardSlotSelector.instance.card_is_selected():
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
		place_tile(cell + offset_coordinate, TileDataManager.instance.tile_dictionnary[RANGE_TILE_KEY]);

func on_tile_hover_out(_cell: Vector2i):
	if is_tile_range_displayed:
		is_tile_range_displayed = false;
		clear_tilemap();
		update_valid_cells();
