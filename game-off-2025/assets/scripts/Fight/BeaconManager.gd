extends Node2D
class_name BeaconManager

static var health: int;
static var instance : BeaconManager;

func _ready() -> void:
	health = Constants.beacon_hp;
	SignalBus.beacon_health_updated.emit(health);
	if instance == null:
		instance = self;

func damage(damages: int):
	if health <= 0: return;
	
	health = min(health - damages, Constants.beacon_hp);
	MonsterInfo.launch_monster_info("-" + str(damage), TileDataManager.beacon_icon_small, MainTilemap.instance.beacon_sprite.position, self, Color.DARK_RED);
	SignalBus.beacon_health_updated.emit(health);
	
	if health <= 0:
		health = 0;
		SignalBus.game_lost.emit()
	else:
		MainTilemap.instance.execute_all_tile_effects(TileDataManager.TRIGGERS.ON_BEACON_DAMAGE);


func heal(heal_amount: int):
	if health <= 0: return;
	
	health = min(health + heal_amount, Constants.beacon_hp);
	#MonsterInfo.launch_monster_info("-" + str(damage), TileDataManager.beacon_icon_small, MainTilemap.instance.beacon_sprite.position, self, Color.DARK_RED);
	SignalBus.beacon_health_updated.emit(health);
