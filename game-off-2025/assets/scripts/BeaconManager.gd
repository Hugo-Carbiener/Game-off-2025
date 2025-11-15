extends Node
class_name BeaconManager

static var health: int = Constants.beacon_hp;
static var instance : BeaconManager;

signal beacon_hp_updated;

func _ready() -> void:
	beacon_hp_updated.emit(health)
	
	if instance == null:
		instance = self;
		
func damage(damages: int):
	health -= damages;
	if health < 0: 
		health = 0;
		
	beacon_hp_updated.emit(health)
	
	if health <= 0:
		get_tree().paused = true
		get_node("../Death Screen").visible = true
	
