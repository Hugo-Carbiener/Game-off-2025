extends Node2D
class_name BeaconManager

static var health: int = Constants.beacon_hp;
static var instance : BeaconManager;

func _ready() -> void:
	SignalBus.beacon_health_updated.emit(health);
	if instance == null:
		instance = self;

func damage(damages: int):
	if health <= 0: return;
	
	health -= damages;
	SignalBus.beacon_health_updated.emit(health);

	if health <= 0:
		health = 0;
		SignalBus.game_lost.emit()
