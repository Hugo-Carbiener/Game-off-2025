extends TilemapManager
class_name MonsterFactory

@export_group("Breaches variables")
@export var breach_tiles_per_maturity : Dictionary[int, String];
static var monsters : Dictionary[Vector2i, Monster];
static var breaches : Dictionary[Vector2i, Breach];
static var instance : MonsterFactory;
@export_group("Monster path variables")
@export var monster_movement_duration : float;
@export var indicator_tilemap : TileMapLayer;
@export var monster_sprite : Sprite2D;
var last_tile_hovered : Vector2i = Vector2i.ZERO;

func _ready() -> void:
	super();
	if instance == null:
		instance = self;

func is_valid_cell(_coordinates : Vector2) -> bool:
	return true;

func spawn_monster(tilemap_position: Vector2i):
	var monster = Monster.new(GameLoop.round_number, tilemap_position, get_monster_path(tilemap_position));
	monsters.set(tilemap_position, monster);
	var monster_tile_data = TileDataManager.tile_dictionnary.get(Constants.TILE_DICT_MONSTER_KEY);
	place_tile(tilemap_position, monster_tile_data);

func spawn_breach(tilemap_position: Vector2i):
	var breach = Breach.new(Constants.breach_initial_maturity, tilemap_position);
	breaches.set(tilemap_position, breach);
	var breach_tile_name = breach_tiles_per_maturity.get(Constants.breach_initial_maturity);
	var breach_tile_data = TileDataManager.tile_dictionnary.get(breach_tile_name);
	place_tile(tilemap_position, breach_tile_data);

func remove_breach(tilemap_position: Vector2i):
	if !breaches.has(tilemap_position): return;
	
	breaches.erase(tilemap_position);
	clear_cell(tilemap_position);

func remove_monster(tilemap_position: Vector2i):
	if !monsters.has(tilemap_position): return;
	
	monsters.erase(tilemap_position);
	clear_cell(tilemap_position);

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
	# Get monsters from furthest to closest 
	var monster_positions = monsters.keys();
	monster_positions.sort_custom(func(a,b) : return cell_manhattan_distance(a, Vector2i.ZERO) < cell_manhattan_distance(b, Vector2i.ZERO));
	var monster_list = monster_positions.map(func(a): return monsters.get(a));
	
	var monster_count = monster_list.size();
	var monster_idx = 0;
	while monster_count > 0:
		monster_idx = (monster_idx -1) % monster_count;
		var monster = monster_list[monster_idx];
			
		if monster.is_at_destination() or monster.is_dead():
			monster_list.remove_at(monster_idx);
			monster_count = monster_list.size();
			continue;
		var from = monster.tilemap_position;
		var to = monster.get_next_position();
		var tween = get_tree().create_tween();
		tween.tween_callback(func(): monster.on_move_start(self));
		tween.tween_callback(func(): on_move_start(from));
		tween.tween_property(monster_sprite, "position", map_to_local(to), monster_movement_duration).from(map_to_local(from));
		tween.tween_callback(func(): on_move_end(to));
		tween.tween_callback(func(): monster.on_move_end(self));
		await tween.finished;
	compute_monster_positions();

func on_move_start(_from : Vector2i):
	monster_sprite.visible = true;

func on_move_end(_to : Vector2i):
	monster_sprite.visible = false;

func compute_monster_positions():
	var monster_list = monsters.values();
	if monster_list.size() == 0: return;
	monsters.clear();
	for monster in monster_list:
		monsters.set(monster.tilemap_position, monster);

## MONSTER PATH

func get_monster_path(from : Vector2i) -> Array[Vector2i]:
	return get_line_cells(from, Vector2i.ZERO);

# Bresenham line algorithm
func get_line_cells(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = [];
	var x0 = start.x;
	var y0 = start.y;
	var x1 = end.x;
	var y1 = end.y;

	var dx = abs(x1 - x0);
	var dy = -abs(y1 - y0);
	var sx = 1 if x0 < x1 else -1;
	var sy = 1 if y0 < y1 else -1;
	var err = dx + dy;  # error term

	while true:
		cells.append(Vector2i(x0, y0));
		if x0 == x1 and y0 == y1:
			break;
		var e2 = 2 * err;
		if e2 >= dy:
			err += dy;
			x0 += sx;
			continue;
		if e2 <= dx:
			err += dx;
			y0 += sy;
			continue;
	cells.pop_front();
	return cells

## MONSTER HOVER

func _input(event):
	check_for_enemy_hover(event);

func check_for_enemy_hover(event : InputEvent):
	if event is not InputEventMouseMotion: return;
	
	if DragAndDropHandler.is_dragging : return;
	var cell = local_to_map(get_local_mouse_position());
	if cell != last_tile_hovered: 
		if has_tile_at(cell):
			on_enemy_hover_in(cell);
		elif last_tile_hovered != Vector2i.ZERO:
			on_enemy_hover_out();

func on_enemy_hover_in(cell: Vector2i):
	last_tile_hovered = cell;
	var monster = monsters.get(cell);
	if monster == null: return;
	
	for trajectory_point in monster.trajectory:
		indicator_tilemap.set_cell(trajectory_point, 0, TileDataManager.tile_dictionnary.get(Constants.TILE_DICT_MONSTER_PATH_KEY).atlas_coordinates);

func on_enemy_hover_out():
	last_tile_hovered = Vector2i.ZERO;
	indicator_tilemap.clear();
