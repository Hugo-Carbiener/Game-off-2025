extends TilemapManager
class_name MonsterFactory

static var monsters : Dictionary[Vector2i, Monster];
static var breaches : Dictionary[Vector2i, Breach];
static var instance : MonsterFactory;
@export_group("Components")
@export var monster_health_indicator : MonsterHealthIndicator;
@export_group("Breaches variables")
@export var breach_models : Array[BreachData];
@export var breach_intro_animation_per_maturity : Dictionary[int, String];
@export var breach_animated_sprite : AnimatedSprite2D;
@export_group("Monster variables")
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

func execute_breaches_intent():
	for breach in breaches.values():
		if breach == null: return;
		
		breach.execute_intent();

func spawn_monster(breach : Breach):
	var _position = breach.get_free_weak_point_position();
	add_monster(GameLoop.current_day + 1, _position);

func add_monster(health : int, tilemap_position : Vector2i):
	var monster = Monster.new(health, tilemap_position, get_monster_path(tilemap_position));
	monsters.set(tilemap_position, monster);
	var monster_tile_data = TileDataManager.tile_dictionnary.get(Constants.TILE_DICT_MONSTER_KEY);
	place_tile(tilemap_position, monster_tile_data);

func spawn_breach(tilemap_position: Vector2i, turn_delay : int):
	var breach = await Breach.create_breach(tilemap_position, turn_delay, breach_models[randi() % breach_models.size()], self);
	breaches.set(tilemap_position, breach);
	SignalBus.breach_spawned.emit();

func remove_breach(tilemap_position: Vector2i):
	if !breaches.has(tilemap_position): return;
	
	breaches.erase(tilemap_position);
	clear_tile(tilemap_position);

func remove_monster(tilemap_position: Vector2i):
	if !monsters.has(tilemap_position): return;
	
	monsters.erase(tilemap_position);
	clear_tile(tilemap_position);

func on_setup():
	if GameLoop.is_breach_spawn_day():
		var breach_max_range = min(Constants.beacon_range, Constants.breach_min_spawn_range + breaches.size());
		var valid_breach_positions = MainTilemap.instance.get_valid_monster_spawn_positions(Constants.breach_min_spawn_range, breach_max_range);
		if valid_breach_positions.size()>0:
			var breach_position = valid_breach_positions[randi() % valid_breach_positions.size()];
			MonsterFactory.instance.spawn_breach(breach_position, Constants.breach_setup_delay);
	
	for breach_index in range(breaches.size()):
		var breach = breaches.values()[breach_index];
		if breach_index == breaches.size() - 1:
			await breach.update_breach();
		else: 
			breach.update_breach();

func on_resolution():
	execute_breaches_intent();
	# Get monsters from closest to furthest  
	var sorted_monsters = monsters.values();
	sorted_monsters.sort_custom(func(a,b) : return cell_manhattan_distance(monsters.find_key(a), Vector2i.ZERO) < cell_manhattan_distance(monsters.find_key(b), Vector2i.ZERO))
	for monster in sorted_monsters:
		await execute_monster_trajectory(monster);
	
	for breach in breaches.values():
		await breach.apply_tile_interactions();

func execute_monster_trajectory(monster : Monster):
	on_move_start(monster);
	for monster_destination in monster.trajectory:
		var to = monster_destination;
		if monster.is_at_destination() or monster.is_dead():
			break;
	
		var tween = get_tree().create_tween();
		tween.set_parallel(true);
		tween.tween_property(monster_sprite, "position", map_to_local(to), Constants.monster_movement_duration);
		tween.tween_property(monster_health_indicator, "position", map_to_local(to), Constants.monster_movement_duration);
		await tween.finished;
		await on_step_end(monster, monster_destination);
	on_move_end();

func on_move_start(monster : Monster):
	monster_sprite.position = map_to_local(monster.tilemap_position);
	monster_sprite.visible = true;
	monster_health_indicator.position = monster_sprite.position;
	monster_health_indicator.setup(monster);
	monster_health_indicator.visible = true;
	clear_tile(monster.tilemap_position);
	monsters.erase(monster.tilemap_position);

func on_move_end():
	monster_sprite.visible = false;
	monster_health_indicator.visible = false;

func on_step_end(monster : Monster, tilemap_position : Vector2i):
	if breaches.has(tilemap_position):
		show_tile(tilemap_position);
	await monster.on_step_end();

func dispatch_monster_damage(monster : Monster, damage_amount : int, is_ranged : bool):
	monster_damage_animated_sprite.visible = true;
	monster_damage_animated_sprite.position = map_to_local(monster.tilemap_position);
	monster_damage_animated_sprite.play();
	await monster_damage_animated_sprite.animation_finished;
	monster_damage_animated_sprite.visible = false;
	monster_health_indicator.on_damage(monster, damage_amount, is_ranged);

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
		add_monster(GameLoop.current_day + 1, monster_position);
		#TODO : save breaches
	#for breach_position in _breaches.keys():
		#spawn_breach(breach_position, _breaches[breach_position]);
