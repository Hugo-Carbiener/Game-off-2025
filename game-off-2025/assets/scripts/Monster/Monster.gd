class_name Monster

var health : int;
var max_health : int;
var tilemap_position : Vector2i;
var trajectory : Array[Vector2i];
var position_in_trajectory : int;
var reached_destination : Signal;
var health_weakness : int;
var damage_weakness : int;

func _init(_health: int, _tilemap_position: Vector2i, _trajectory : Array[Vector2i]):
	self.health = _health;
	self.max_health = _health;
	self.tilemap_position = _tilemap_position;
	self.trajectory = _trajectory
	self.position_in_trajectory = 0;
	self.health_weakness = 0;
	self.damage_weakness = 0;

func on_step_end():
	tilemap_position = trajectory[position_in_trajectory];
	
	if is_at_destination():
		BeaconManager.instance.damage(health - damage_weakness);
		on_death();
	
	await MainTilemap.instance.apply_tile_damage(tilemap_position, self);
	await MainTilemap.instance.execute_tile_effects(TileDataManager.TRIGGERS.ON_MONSTER_WALK, tilemap_position);
	await MainTilemap.instance.apply_ranged_tile_damage(tilemap_position, self);
	await MainTilemap.instance.execute_ranged_tile_effects(TileDataManager.TRIGGERS.ON_MONSTER_WALK, tilemap_position);
	position_in_trajectory +=1;

func get_next_position() -> Vector2i:
	var trajectory_idx = trajectory.find(tilemap_position);
	trajectory_idx = min(trajectory_idx, trajectory.size()-2);
	trajectory_idx = max(trajectory_idx, 0);
	return trajectory[trajectory_idx + 1];

func damage(damage_amount : int, damage_source_position : Vector2i):
	if damage_amount <= 0: return;
	
	health -= damage_amount + health_weakness;
	
	var is_ranged = damage_source_position != tilemap_position;
	#var monster_info_texture = TileDataManager.ranged_damage_icon_small if is_ranged else TileDataManager.damage_icon_small;
	#MonsterInfo.launch_monster_info("-" + str(damage_amount), monster_info_texture, MainTilemap.instance.map_to_local(damage_source_position), MonsterFactory.instance);
	AnimationUtils.blink_sprite(MonsterFactory.instance.monster_sprite);
	await MonsterFactory.instance.dispatch_monster_damage(self, damage_amount, is_ranged);
	
	if is_dead():
		on_death();
		return;

func on_death():
	MainTilemap.instance.execute_tile_effects(TileDataManager.TRIGGERS.ON_MONSTER_DEATH, tilemap_position);
	MonsterFactory.instance.clear_tile(tilemap_position);
	MonsterFactory.monsters.erase(tilemap_position);

func is_dead() -> bool:
	return health <= 0;

func is_at_destination() -> bool:
	return tilemap_position == Vector2i.ZERO;
