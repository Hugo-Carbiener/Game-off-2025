extends Node2D
class_name GameLoop

@export_group("UI elements")
@export var death_screen : Control;
@export var win_screen : Control;
@export_group("UI buttons")
@export var lose_button : TextureButton;
@export var win_button : TextureButton;

enum PHASES {SETUP, PLAY, RESOLUTION}
static var phase_start_sequences = {
	PHASES.SETUP : Callable(setup_phase),
	PHASES.PLAY : Callable(play_phase),
	PHASES.RESOLUTION : Callable(resolution_phase)
}
static var instance;
static var current_phase : PHASES = PHASES.SETUP;
static var round_number : int = 0;

func _ready() -> void:
	if instance == null:
		instance = self;
	lose_button.button_up.connect(quit_game);
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
	pass;

static func resolution_phase():
	await MonsterFactory.instance.on_resolution();
	start_phase(get_next_phase());

func loose_game():
	get_tree().paused = true
	death_screen.visible = true

func win_game():
	get_tree().paused = true
	win_screen.visible = true

func quit_game():
	get_tree().quit();
