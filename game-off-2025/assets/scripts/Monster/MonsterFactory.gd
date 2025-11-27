extends TilemapManager
class_name MonsterFactory

@export_group("Breaches variables")
@export var breach_tiles_per_maturity : Dictionary[int, String];
@export var breach_intro_animation_per_maturity : Dictionary[int, String];
@export var breach_animated_sprite : AnimatedSprite2D;
static var monsters : Dictionary[Vector2i, Monster];
static var breaches : Dictionary[Vector2i, Breach];
static var instance : MonsterFactory;
@export_group("Monster path variables")
@export var monster_movement_duration : float;
@export var indicator_tilemap : TileMapLayer;
@export var monster_sprite : Sprite2D;
@export_group("Monster info variables")
@export var monster_info_pool : Node2D;
const monster_info_model : PackedScene = preload("res://scenes/MonsterInfo.tscn");
var last_tile_hovered : Vector2i = Vector2i.ZERO;

## monster status
enum STATUS {
	WET,
	POISON,
	SPRAINED
}

func _ready() -> void:
	super();
	if instance == null:
		instance = self;

func spawn_monster(tilemap_position: Vector2i):
	var monster = Monster.new(GameLoop.round_number, tilemap_position, get_monster_path(tilemap_position));
	monsters.set(tilemap_position, monster);
	var monster_tile_data = TileDataManager.instance.tile_dictionnary.get(Constants.TILE_DICT_MONSTER_KEY);
	place_tile(tilemap_position, monster_tile_data);

func spawn_breach(tilemap_position: Vector2i):
	var breach = Breach.new(Constants.breach_initial_maturity, tilemap_position);
	breaches.set(tilemap_position, breach);
	var breach_tile_name = breach_tiles_per_maturity.get(Constants.breach_initial_maturity);
	var breach_tile_data = TileDataManager.instance.tile_dictionnary.get(breach_tile_name);
	
	await breach_transition(tilemap_position, Constants.breach_initial_maturity);
	place_tile(tilemap_position, breach_tile_data);

func breach_transition(tilemap_position : Vector2i, breach_maturity : int):
	var tween = get_tree().create_tween();
	tween.tween_callback(func(): breach_animated_sprite.visible = true);
	tween.tween_callback(func(): breach_animated_sprite.position = map_to_local(tilemap_position));
	tween.tween_callback(func(): breach_animated_sprite.frame = 0);
	tween.tween_callback(func(): breach_animated_sprite.animation = breach_intro_animation_per_maturity[breach_maturity]);
	tween.tween_property(breach_animated_sprite, "frame", breach_animated_sprite.sprite_frames.get_frame_count(breach_intro_animation_per_maturity[breach_maturity]), Constants.breach_transition_duration);
	tween.tween_callback(func(): breach_animated_sprite.visible = false);
	print("Tweening breach at " + str(tilemap_position));
	await tween.finished;
	return;

func remove_breach(tilemap_position: Vector2i):
	if !breaches.has(tilemap_position): return;
	
	breaches.erase(tilemap_position);
	clear_tile(tilemap_position);

func remove_monster(tilemap_position: Vector2i):
	if !monsters.has(tilemap_position): return;
	
	monsters.erase(tilemap_position);
	clear_tile(tilemap_position);

func update_breach_tile(tilemap_position: Vector2i):
	var breach = breaches.get(tilemap_position);
	if breach == null: return;
	
	var breach_tile_name = breach_tiles_per_maturity.get(breach.turn_remaining);
	var breach_tile_data = TileDataManager.instance.tile_dictionnary.get(breach_tile_name);
	set_cell(tilemap_position, 0, Vector2(-1,-1));
	await MonsterFactory.instance.breach_transition(tilemap_position, breach.turn_remaining);
	set_cell(tilemap_position, 0, breach_tile_data.atlas_coordinates);

func on_setup():
	for breach in breaches.values():
		await breach.update();
	return;

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
		var from = monster.tilemap_position;
		var to = monster.get_next_position();
		
		if monster.is_at_destination() or monster.is_dead():
			monster_list.remove_at(monster_idx);
			monster_count = monster_list.size();
			continue;
		if monster.is_under_fatigue() or monsters.has(to):
			monster.on_stay();
			continue;
		var tween = get_tree().create_tween();
		tween.tween_callback(func(): monster.on_move_start(self));
		tween.tween_callback(func(): on_move_start(monster, from));
		tween.tween_property(monster_sprite, "position", map_to_local(to), monster_movement_duration);
		tween.tween_callback(func(): on_move_end(monster, to));
		tween.tween_callback(func(): monster.on_move_end(self));
		await tween.finished;

func on_move_start(_monster : Monster, from : Vector2i):
	monster_sprite.position = map_to_local(from);
	monster_sprite.visible = true;
	monsters.erase(from);

func on_move_end(monster : Monster, _to : Vector2i):
	monster_sprite.visible = false;
	monsters.set(_to, monster);

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
	return cells

## MONSTER HOVER

func _input(event):
	check_for_enemy_hover(event);

func check_for_enemy_hover(event : InputEvent):
	if event is not InputEventMouseMotion: return;
	
	var cell = local_to_map(get_local_mouse_position());
	if cell != last_tile_hovered: 
		if has_tile_at(cell):
			on_enemy_hover_in(cell);
		elif last_tile_hovered != Vector2i.ZERO:
			on_enemy_hover_out();

func on_enemy_hover_in(cell: Vector2i):
	if last_tile_hovered != cell:
		indicator_tilemap.clear_tilemap();
	last_tile_hovered = cell;
	var monster = monsters.get(cell);
	if monster == null: return;
	
	for trajectory_point in monster.trajectory:
		indicator_tilemap.place_tile(trajectory_point, TileDataManager.instance.tile_dictionnary.get(Constants.TILE_DICT_MONSTER_PATH_KEY));

func on_enemy_hover_out():
	last_tile_hovered = Vector2i.ZERO;
	indicator_tilemap.clear_tilemap();

func get_free_monster_info_model():
	for monster_info in monster_info_pool.get_children():
		if monster_info.visible: continue;
		print("found existing element in pool")
		return monster_info;
	return add_monster_info_to_pool();

func add_monster_info_to_pool():
	print("adding element to pool")
	var monster_info = monster_info_model.instantiate();
	monster_info_pool.add_child(monster_info);
	return monster_info;

func spawn_interaction(monster : Monster, text : String, icons : Array[ImageTexture]):
	var monster_tilemap_position = monsters.find_key(monster);
	var monster_info = get_free_monster_info_model();
	if monster_tilemap_position == null: return;
	
	var info_position = map_to_local(monster_tilemap_position);
	monster_info.launch(info_position, text, icons);
