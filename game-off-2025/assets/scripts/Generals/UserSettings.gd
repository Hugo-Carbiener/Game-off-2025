extends Node2D

var are_input_blocked = false;

func _ready() -> void:
	SignalBus.evolution_started.connect(func(): are_input_blocked = true);
	SignalBus.evolution_finished.connect(func(): are_input_blocked = false);
	
