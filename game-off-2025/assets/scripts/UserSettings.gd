extends Node2D

var areInputBlocked = false;

func _ready() -> void:
	SignalBus.evolution_started.connect(func(): areInputBlocked = true);
	SignalBus.evolution_finished.connect(func(): areInputBlocked = false);
	SignalBus.play_phase_started.connect(func(): areInputBlocked = false);
	SignalBus.resolution_phase_started.connect(func(): areInputBlocked = true);
