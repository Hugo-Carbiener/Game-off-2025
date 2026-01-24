extends TilemapManager
class_name IndicationTilemap

static var instance : IndicationTilemap;
static var VALID_CELL_TILE_KEY = "valid-cell";

var enemy_indications : Array[Vector2i];

func _ready() -> void:
	super();
	if instance == null:
		instance = self;
	SignalBus.card_used.connect(update_valid_cells);
	SignalBus.evolution_started.connect(reset_valid_cells);
	SignalBus.evolution_started.connect(reset_valid_cells);
	SignalBus.resolution_phase_started.connect(reset_valid_cells);

func on_enemy_hover_in(cell: Vector2i, last_tile_hovered : Vector2i):
	if last_tile_hovered != cell:
		clear_enemy_indications();
	var monster = MonsterFactory.instance.monsters.get(cell);
	if monster == null: return;
	
	for trajectory_point in monster.trajectory:
		if trajectory_point == Vector2i.ZERO: continue;
		if tiles.has(trajectory_point): continue; # do not overwrite valid cells
		
		enemy_indications.append(trajectory_point);
		place_tile(trajectory_point, TileDataManager.instance.tile_dictionnary.get(Constants.TILE_DICT_MONSTER_PATH_KEY));

func on_enemy_hover_out():
	clear_enemy_indications();

func clear_enemy_indications():
	for tile in enemy_indications:
		clear_tile(tile);

func display_valid_cells():
	var valid_cells = MainTilemap.instance.get_valid_cells();
	for valid_cell in valid_cells:
		place_tile(valid_cell, TileDataManager.instance.tile_dictionnary[VALID_CELL_TILE_KEY]);

func update_valid_cells(_card_amount : int = 0):
	if CardSlotSelector.instance.card_is_selected():
		reset_valid_cells();
		display_valid_cells();

func reset_valid_cells():
	clear_tilemap();
