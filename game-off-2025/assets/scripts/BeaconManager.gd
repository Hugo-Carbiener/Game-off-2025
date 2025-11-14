extends Node
class_name BeaconManager

static var health: int = Constants.beacon_hp;

static var instance : BeaconManager;

func _ready() -> void:
	if instance == null:
		instance = self;
		
func damage(damages: int):
	health -= damages;
	print_debug('remaining', health)
	if health <= 0:
		print_debug('dead')
		get_tree().paused = true
		get_node("../Death Screen").visible = true
	
