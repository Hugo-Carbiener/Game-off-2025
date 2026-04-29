extends Node2D
class_name BeaconManager

static var health: int;
static var shield: int;
static var instance : BeaconManager;

func _ready() -> void:
	health = Constants.beacon_hp;
	SignalBus.beacon_health_updated.emit(health);
	if instance == null:
		instance = self;

func damage(damage_amount: int):
	if health <= 0: return;
	
	health = min(health - damage_amount, Constants.beacon_hp);
	SignalBus.beacon_health_updated.emit(health);
	
	if health <= 0:
		health = 0;
		SignalBus.game_lost.emit()
	else:
		MainTilemap.instance.execute_all_tile_effects(TileDataManager.TRIGGERS.ON_BEACON_DAMAGE);

func heal(heal_amount: int):
	if health <= 0: return;
	
	health = min(health + heal_amount, Constants.beacon_hp);
	SignalBus.beacon_health_updated.emit(health);

func add_shield(shield_amount : int):
	if health <= 0: return;
	
	shield += max(0, shield_amount);
	SignalBus.beacon_health_updated.emit(health);

func on_resolution_end():
	shield = 0;
	# TODO: dispatch shield fade on resolution end
	SignalBus.beacon_health_updated.emit(health);
