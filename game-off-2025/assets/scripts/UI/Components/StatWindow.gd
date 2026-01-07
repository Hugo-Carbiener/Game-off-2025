extends MarginContainer
class_name StatWindow

@export var beacon_health_bar : TextureProgressBar;
@export var round_number_label : Label;
@export var current_tile_label : Label;
@export var max_tile_label : Label;

func _ready() -> void:
	SignalBus.beacon_health_updated.connect(on_beacon_health_change);
	SignalBus.round_started.connect(on_new_round);
	SignalBus.tile_placed.connect(on_tile_placed);
	max_tile_label.text = str(TileDataManager.instance.world_tile_amount);

func on_beacon_health_change(health: int):
	beacon_health_bar.value  = round(health * 100.0 / Constants.beacon_hp);

func on_new_round(round_number: int):
	round_number_label.text  = str(round_number);

func on_tile_placed(tile_amount : int):
	current_tile_label.text = str(tile_amount);
