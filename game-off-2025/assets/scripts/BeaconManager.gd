extends Node
class_name BeaconManager

static var health: int = Constants.beacon_hp;
static var instance : BeaconManager;

signal beacon_hp_updated;
signal beacon_tile_placed;

func _ready() -> void:
	beacon_hp_updated.emit(health)
	beacon_tile_placed.connect(on_tile_placed);
	if instance == null:
		instance = self;

func damage(damages: int):
	health -= damages;
	if health < 0: 
		health = 0;
		
	beacon_hp_updated.emit(health)
	
	if health <= 0:
		UIUtils.instance.loose_game();

func on_tile_placed():
	if MainTilemap.instance.tiles.size() >= TileDataManager.instance.world_tile_amount:
		UIUtils.instance.win_game();
