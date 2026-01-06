extends TilemapManager
class_name IndicationTilemap

static var instance : IndicationTilemap;
static var VALID_CELL_TILE_KEY = "valid-cell";

var enemy_indications : Array[Vector2i];

func _ready() -> void:
	super();
	if instance == null:
		instance = self;
	SignalBus.card_used.connect(on_card_used);

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

func on_card_selection():
	var valid_cells = MainTilemap.instance.get_valid_cells();
	for valid_cell in valid_cells:
		place_tile(valid_cell, TileDataManager.instance.tile_dictionnary[VALID_CELL_TILE_KEY]);

func on_card_used(_card_amount : int):
	if CardSlotSelector.instance.card_is_selected():
		clear_tilemap();
		on_card_selection();

func on_card_unselection():
	clear_tilemap();
