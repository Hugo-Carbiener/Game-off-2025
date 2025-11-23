extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.reroll_amount_updated.connect(_on_reroll_amount_updated);
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_beacon_manager_beacon_hp_updated(health: int) -> void:
	@warning_ignore("integer_division")
	get_node("BeaconHPBar").value  = round(health * 100 / Constants.beacon_hp)

func _on_reroll_amount_updated(number: int):
	get_node('RerollLabel').text = str(number);
