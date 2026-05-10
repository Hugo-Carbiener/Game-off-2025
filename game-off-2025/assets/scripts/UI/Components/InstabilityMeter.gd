class_name InstabilityMeter extends Control

const instability_meter_scene : PackedScene = preload("res://scenes/components/InstabilityMeter.tscn");

@export var meter : TextureProgressBar;
@export var knob : ProgressBarKnob;
@export var transition_duration : float;

static func create_instability_meter(base_value : int) -> InstabilityMeter:
	var instability_meter = instability_meter_scene.instantiate();
	instability_meter.setup(base_value);
	return instability_meter;

func setup(base_value : int):
	meter.value = base_value;
	knob.update_position();

func update_value(to : int):
	var start_value = meter.value;
	var tween = get_tree().create_tween();
	tween.tween_method(
	setup,
	start_value,
	to,
	transition_duration);    
