extends Control

signal updateBeaconHp;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_beacon_manager_beacon_hp_updated(health: int) -> void:
	get_node("BeaconHPBar").value  = health * 100 / Constants.beacon_hp
