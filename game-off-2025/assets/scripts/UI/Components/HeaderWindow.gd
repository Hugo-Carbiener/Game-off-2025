class_name HeaderWindow extends Control

@export var beacon_health_text : Label;
@export var beacon_health_bar : TextureProgressBar;
@export var monster_health_text : Label;
@export var breach_amount_text : Label;

func _ready() -> void:
	setup_progress_bar();
	update_beacon_health(BeaconManager.instance.health);
	update_monster_health(GameLoop.current_day);
	update_breach_amount();
	SignalBus.beacon_health_updated.connect(update_beacon_health);
	SignalBus.setup_phase_started.connect(update_monster_health);
	SignalBus.breach_spawned.connect(update_breach_amount);

func setup_progress_bar():
	beacon_health_bar.min_value = 0;
	beacon_health_bar.max_value = Constants.beacon_hp;
	beacon_health_bar.value = BeaconManager.instance.health;

func update_beacon_health(beacon_health : int):
	beacon_health_text.text = str(beacon_health) + "/" + str(Constants.beacon_hp);
	beacon_health_bar.value = beacon_health;

func update_breach_amount():
	breach_amount_text.text = str(MonsterFactory.breaches.size()) + "/" + str(Constants.base_breach_amount);

func update_monster_health(current_day : int):
	monster_health_text.text = str(current_day);
