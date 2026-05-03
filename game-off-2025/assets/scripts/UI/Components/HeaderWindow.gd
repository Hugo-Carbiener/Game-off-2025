class_name HeaderWindow extends Control

@export var beacon_health_text : Label;
@export var monster_health_text : Label;

func _ready() -> void:
	update_beacon_health(BeaconManager.instance.health);
	update_monster_health(GameLoop.day_number);
	SignalBus.beacon_health_updated.connect(update_beacon_health);
	SignalBus.setup_phase_started.connect(update_monster_health);

func update_beacon_health(beacon_health : int):
	beacon_health_text.text = str(beacon_health) + "/" + str(Constants.beacon_hp);
	AnimationUtils.bounce(beacon_health_text, 1.5);

func update_monster_health(day_number : int):
	monster_health_text.text = str(day_number);
	AnimationUtils.bounce(monster_health_text, 1.5);
