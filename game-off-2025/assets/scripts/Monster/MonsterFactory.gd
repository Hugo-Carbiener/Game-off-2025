extends TilemapManager
class_name MonsterFactory

static var monsters : Dictionary[Vector2i, Monster];
static var breaches : Dictionary[Vector2i, int];
static var instance : MonsterFactory;

@export_group("Breaches variables")
@export var breach_tiles_per_maturity : Dictionary[int, String];
@export var breach_intro_animation_per_maturity : Dictionary[int, String];
@export var breach_animated_sprite : AnimatedSprite2D;
@export_group("Monster variables")
@export var monster_movement_duration : float;
@export var indicator_tilemap : TileMapLayer;
@export var monster_sprite : Sprite2D;
@export var monster_damage_animated_sprite : AnimatedSprite2D;

func _ready() -> void:
	super();
	if instance == null:
		instance = self;
	init_sprites();

func init_sprites():
	monster_sprite.visible = false;
	breach_animated_sprite.visible = false;
	monster_damage_animated_sprite.visible = false;

func spawn_monster(tilemap_position: Vector2i):
	var monster = Monster.new(5, tilemap_position, get_monster_path(tilemap_position));
	monsters.set(tilemap_position, monster);
	var monster_tile_data = TileDataManager.tile_dictionnary.get(Constants.TILE_DICT_MONSTER_KEY);
	place_tile(tilemap_position, monster_tile_data);

func spawn_breach(tilemap_position: Vector2i, breach_maturity : int):
	breaches.set(tilemap_position, breach_maturity);
	var breach_tile_name = breach_tiles_per_maturity.get(Constants.breach_initial_maturity);
	var breach_tile_data = TileDataManager.tile_dictionnary.get(breach_tile_name);
	
	await breach_transition(tilemap_position, Constants.breach_initial_maturity);
	place_tile(tilemap_position, breach_tile_data);

func breach_transition(tilemap_position : Vector2i, breach_maturity : int):
	var tween = get_tree().create_tween();
	tween.tween_callback(func(): breach_animated_sprite.visible = true);
	tween.tween_callback(func(): breach_animated_sprite.position = map_to_local(tilemap_position));
	tween.tween_callback(func(): breach_animated_sprite.frame = 0);
	tween.tween_callback(func(): breach_animated_sprite.animation = breach_intro_animation_per_maturity[breach_maturity]);
	tween.tween_property(breach_animated_sprite, "frame", breach_animated_sprite.sprite_frames.get_frame_count(breach_intro_animation_per_maturity[breach_maturity]), Constants.default_transition_duration);
	tween.tween_callback(func(): breach_animated_sprite.visible = false);
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

func update_breach(tilemap_position: Vector2i):
	if !breaches.has(tilemap_position): return;
	var breach_maturity = breaches.get(tilemap_position);
	
	var breach_tile_name = breach_tiles_per_maturity.get(breach_maturity);
	var breach_tile_data = TileDataManager.tile_dictionnary.get(breach_tile_name);
	set_cell(tilemap_position, 0, Vector2(-1,-1));
	await MonsterFactory.instance.breach_transition(tilemap_position, breach_maturity);
	set_cell(tilemap_position, 0, breach_tile_data.atlas_coordinates);

func cover_breach(tilemap_position: Vector2i):
	breaches.erase(tilemap_position);
	clear_tile(tilemap_position);

func on_setup():
	for breach_position in breaches.keys():
		var turn_remaining = breaches[breach_position];
		turn_remaining -= 1;
		breaches.set(breach_position, turn_remaining);
		if turn_remaining == 0:
			remove_breach(breach_position);
			spawn_monster(breach_position);
		else:
			await update_breach(breach_position);
	return;

func on_resolution():
	# Get monsters from furthest to closest 
	var sorted_monsters = monsters.values();
	sorted_monsters.sort_custom(func(a,b) : return cell_manhattan_distance(monsters.find_key(a), Vector2i.ZERO) < cell_manhattan_distance(monsters.find_key(b), Vector2i.ZERO))
	for monster in sorted_monsters:
		await execute_monster_trajectory(monster);

func execute_monster_trajectory(monster : Monster):
	on_move_start(monster);
	for monster_destination in monster.trajectory:
		var to = monster_destination;
		if monster.is_at_destination() or monster.is_dead():
			break;
	
		var tween = get_tree().create_tween();
		tween.tween_property(monster_sprite, "position", map_to_local(to), monster_movement_duration);
		await tween.finished;
		await on_step_end(monster);
	on_move_end();

func on_move_start(_monster : Monster):
	monster_sprite.position = map_to_local(_monster.tilemap_position);
	monster_sprite.visible = true;
	clear_tile(_monster.tilemap_position);
	monsters.erase(_monster.tilemap_position);

func on_step_end(monster : Monster):
	await monster.on_step_end();

func on_move_end():
	monster_sprite.visible = false;

func dispatch_monster_damage(monster : Monster):
	monster_damage_animated_sprite.visible = true;
	monster_damage_animated_sprite.position = map_to_local(monster.tilemap_position);
	monster_damage_animated_sprite.play();
	await monster_damage_animated_sprite.animation_finished;
	monster_damage_animated_sprite.visible = false;

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
	return cells;

func load(_monsters : Array[Vector2i], _breaches : Dictionary[Vector2i, int]):
	for monster_position in _monsters:
		spawn_monster(monster_position);
	for breach_position in _breaches.keys():
		spawn_breach(breach_position, _breaches[breach_position]);
