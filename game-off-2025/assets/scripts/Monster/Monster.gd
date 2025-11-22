class_name Monster

var health : int;
var tilemap_position : Vector2i;
var trajectory : Array[Vector2i];
var position_in_trajectory : int;
var turns_stayed_on_tile : int;

var reached_destination : Signal;

func _init(_health: int, _tilemap_position: Vector2i, _trajectory : Array[Vector2i]):
	self.health = _health;
	self.tilemap_position = _tilemap_position;
	self.trajectory = _trajectory
	self.position_in_trajectory = 0;

func on_move_start(monsterFactory : MonsterFactory):
	turns_stayed_on_tile = 0;
	monsterFactory.clear_tile(tilemap_position);
	
	MainTilemap.instance.apply_tile_effects(tilemap_position, self, TileDataManager.TRIGGERS.ON_TILE_LEAVE);

func on_move_end(monsterFactory : MonsterFactory):
	var new_position = trajectory[position_in_trajectory];
	monsterFactory.place_tile(new_position, TileDataManager.tile_dictionnary["monster"]);
	tilemap_position = new_position;
	position_in_trajectory +=1;
	
	MainTilemap.instance.apply_tile_effects(tilemap_position, self, TileDataManager.TRIGGERS.ON_TILE_ENTER);

func on_stay():
	turns_stayed_on_tile += 1;
	MainTilemap.instance.apply_tile_effects(tilemap_position, self, TileDataManager.TRIGGERS.ON_TILE_STAY);

	if is_at_destination():
		BeaconManager.instance.damage(health)

func is_dead() -> bool:
	return health <= 0;

func is_at_destination() -> bool:
	return tilemap_position == Vector2i.ZERO;

func is_under_fatigue() -> bool:
	if !MainTilemap.instance.has_tile_at(tilemap_position): return false;
	return turns_stayed_on_tile < MainTilemap.instance.tiles[tilemap_position].fatigue

func get_next_position() -> Vector2i:
	return trajectory[trajectory.find(tilemap_position) + 1];

func damage(damage_amount : int) -> bool:
	health -= damage_amount;
	if is_dead():
		on_death();
		return false;
	else: 
		return true;

func on_death():
	TileCardFactory.instance.draw_random_card();
	MonsterFactory.instance.clear_tile(tilemap_position);
	MonsterFactory.monsters.erase(tilemap_position);

func give_status(status : MonsterFactory.STATUS):
	pass;
