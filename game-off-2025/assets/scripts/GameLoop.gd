extends Node2D
class_name GameLoop

enum PHASES {SETUP, PLAY, RESOLUTION}
static var phase_start_sequences = {
	PHASES.SETUP : Callable(setup_phase),
	PHASES.PLAY : Callable(play_phase),
	PHASES.RESOLUTION : Callable(resolution_phase)
}

static var current_phase : PHASES = PHASES.SETUP;
static var round_number : int = 0;

func _ready() -> void:
	get_tree().current_scene.ready.connect(start_phase.bind(current_phase));

static func get_next_phase() -> int:
	return PHASES.values()[(current_phase + 1) % PHASES.size()];
 
static func start_phase(phase : PHASES):
	current_phase = phase;
	phase_start_sequences.get(phase).call();

static func setup_phase():
	print("Starting setup phase");
	round_number += 1;
	MonsterFactory.instance.on_setup();
	TileCardFactory.instance.draw_hand();
	start_phase(get_next_phase());

static func play_phase():
	print("Starting play phase");

static func resolution_phase():
	print("Starting resolution phase");
	await MonsterFactory.instance.on_resolution();
	start_phase(get_next_phase());
