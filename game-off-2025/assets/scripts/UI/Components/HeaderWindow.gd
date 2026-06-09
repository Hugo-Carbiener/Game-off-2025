class_name HeaderWindow extends Control

@export var beacon_health_text : Label;
@export var beacon_health_bar : TextureProgressBar;
@export var area_instability_bar : TextureProgressBar;
@export var area_instability_percentage : Label;
@export var monster_health_text : Label;
@export var resource_amount_per_biome : Dictionary[TileDataManager.BIOMES, Label];

func _ready() -> void:
	update_beacon_health(BeaconManager.instance.health);
	update_monster_health(GameLoop.current_day);
	update_resource_amount(TileDataManager.BIOMES.NATURAL);
	update_resource_amount(TileDataManager.BIOMES.MINERAL);
	update_resource_amount(TileDataManager.BIOMES.ARTIFICIAL);
	setup_beacon_health_bar();
	await setup_area_instability();
	SignalBus.beacon_health_updated.connect(update_beacon_health);
	SignalBus.setup_phase_started.connect(on_setup);
	SignalBus.resource_gained.connect(update_resource_amount);
	SignalBus.resource_used.connect(update_resource_amount);
	SignalBus.breach_instability_changed.connect(update_area_instability);

func setup_beacon_health_bar():
	beacon_health_bar.min_value = 0;
	beacon_health_bar.max_value = Constants.beacon_hp;
	beacon_health_bar.value = 0;

func setup_area_instability():
	area_instability_bar.min_value = 0;
	area_instability_bar.max_value = Constants.base_breach_amount * Constants.breach_max_instability;
	area_instability_bar.value = 0;
	area_instability_percentage.text = "0";

func update_beacon_health(beacon_health : int):
	beacon_health_text.text = str(beacon_health) + "/" + str(Constants.beacon_hp);
	beacon_health_bar.value = beacon_health;

func update_area_instability(_tilemap_position : Vector2i, _instability_value : int):
	await AnimationUtils.animate_integer(set_area_instability_values, round(area_instability_bar.value), GameLoop.area_instability);

func set_area_instability_values(instability_value : int):
	area_instability_bar.value = instability_value;
	var percentage = int(instability_value * 100. / GameLoop.max_area_instability);
	area_instability_percentage.text = str(percentage);

func on_setup(current_day : int):
	update_monster_health(current_day);
	if current_day == 1:
		AnimationUtils.animate_integer(set_area_instability_values, 0, Constants.base_breach_amount * Constants.breach_max_instability, Constants.default_transition_duration);

func update_monster_health(current_day : int):
	monster_health_text.text = str(current_day);

func update_resource_amount(type : TileDataManager.BIOMES):
	resource_amount_per_biome[type].text = str(ResourceManager.instance.essences[type]);
