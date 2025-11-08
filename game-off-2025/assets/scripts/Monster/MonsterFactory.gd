extends TileMapLayer
class_name MonsterFactory

@export_group("Breaches variables")
@export var breach_tiles_per_maturity : Dictionary[int, String];
static var monsters : Dictionary[Vector2i, Monster];
static var breaches : Dictionary[Vector2i, Breach];
static var instance : MonsterFactory;

func _ready() -> void:
	if instance == null:
		instance = self;

func spawn_monster(tilemap_position: Vector2i):
	var monster = Monster.new(GameLoop.round_number, tilemap_position);
	monsters.set(tilemap_position, monster);
	var monster_tile_data = TileDataManager.tile_dictionnary.get("monster");
	set_cell(tilemap_position, 0, monster_tile_data.atlas_coordinates);

func spawn_breach(tilemap_position: Vector2i):
	var breach = Breach.new(Constants.breach_initial_maturity, tilemap_position);
	breaches.set(tilemap_position, breach);
	var breach_tile_name = breach_tiles_per_maturity.get(Constants.breach_initial_maturity);
	var breach_tile_data = TileDataManager.tile_dictionnary.get(breach_tile_name);
	set_cell(tilemap_position, 0, breach_tile_data.atlas_coordinates);

func remove_breach(tilemap_position: Vector2i):
	if !breaches.has(tilemap_position): return;
	
	breaches.erase(tilemap_position);
	set_cell(tilemap_position, 0, Vector2(-1, -1));

func update_breach_tile(tilemap_position: Vector2i):
	var breach = breaches.get(tilemap_position);
	if breach == null: return;
	
	var breach_tile_name = breach_tiles_per_maturity.get(breach.turn_remaining);
	var breach_tile_data = TileDataManager.tile_dictionnary.get(breach_tile_name);
	set_cell(tilemap_position, 0, breach_tile_data.atlas_coordinates);

func on_setup():
	for breach in breaches.values():
		breach.update();

func on_resolution():
	pass;
	
