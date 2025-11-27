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
	await MonsterFactory.instance.on_setup();
	TileCardFactory.instance.draw_hand();
	
	ShockWave.instance.execute_large_shockwave(MainTilemap.instance.tilemap_to_viewport(Vector2i.ZERO));
	for i in range(round_number + Constants.breaches_spawn_increase_per_round):
		var valid_monster_spawns = MainTilemap.instance.get_valid_monster_spawn_positions();
		await MonsterFactory.instance.spawn_breach(valid_monster_spawns[randi() % valid_monster_spawns.size()]);
		
	start_phase(get_next_phase());

static func play_phase():
	await UIUtils.instance.toggle_card_slots();

static func resolution_phase():
	await UIUtils.instance.toggle_card_slots();
	await MonsterFactory.instance.on_resolution();
	start_phase(get_next_phase());
