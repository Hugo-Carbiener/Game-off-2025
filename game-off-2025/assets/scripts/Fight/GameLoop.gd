extends Node2D
class_name GameLoop

enum PHASES {SETUP, PLAY, RESOLUTION}
static var phase_start_sequences = {
	PHASES.SETUP : Callable(setup_phase),
	PHASES.PLAY : Callable(play_phase),
	PHASES.RESOLUTION : Callable(resolution_phase)
}
static var current_phase : PHASES;
static var day_number : int;

func _ready() -> void:
	current_phase = PHASES.SETUP;
	day_number = 0;
	SignalBus.game_saving.connect(save_fight); 
	SignalBus.card_discarded.connect(on_card_discarded);
	SignalBus.tile_placed.connect(on_tile_placed);
	AudioUtils.fade_in(AudioUtils.play_music(AudioUtils.musics[AudioUtils.MUSICS.START]), 2);
	ready.connect(start_game);

func start_game():
	load_fight();
	
	start_phase(current_phase);

static func get_next_phase() -> int:
	return PHASES.values()[(current_phase + 1) % PHASES.size()];
 
static func start_phase(phase: PHASES):
	current_phase = phase;
	await GameUI.instance.display_phase_title(current_phase);
	phase_start_sequences.get(phase).call();

static func setup_phase():
	UserSettings.are_input_blocked = true;
	day_number += 1;
	SignalBus.setup_phase_started.emit(day_number);
	await MonsterFactory.instance.on_setup();
	TileCardFactory.instance.draw_hand();
	
	for i in range(day_number + Constants.breaches_spawn_increase_per_round):
		var valid_monster_spawns = MainTilemap.instance.get_valid_monster_spawn_positions();
		await MonsterFactory.instance.spawn_breach(valid_monster_spawns[randi() % valid_monster_spawns.size()], Constants.breach_initial_maturity);
		
	start_phase(get_next_phase());

static func play_phase():
	SignalBus.play_phase_started.emit();
	UserSettings.are_input_blocked = false;

static func resolution_phase():
	UserSettings.are_input_blocked = true;
	SignalBus.resolution_phase_started.emit();
	
	if MonsterFactory.instance.monsters.is_empty(): 
		start_phase(get_next_phase());
	else:
		await MainCamera.zoom_transition(MainTilemap.instance.position, Vector2i.ONE * 2);
		MainTilemap.instance.execute_all_tile_effects(TileDataManager.TRIGGERS.ON_RESOLUTION_START);
		await MonsterFactory.instance.on_resolution();
		MainTilemap.instance.execute_all_tile_effects(TileDataManager.TRIGGERS.ON_RESOLUTION_END);
		BeaconManager.instance.on_resolution_end();
		await MainCamera.zoom_transition(Vector2i.ZERO, Vector2i.ONE);
		start_phase(get_next_phase());

func on_card_discarded(_tilecard : TileCard):
	# if hand is empty next phase
	if TileCardFactory.instance.cards.is_empty():
		start_phase(get_next_phase());

func on_tile_placed(tile_amount : int):
	if tile_amount >= TileDataManager.world_tile_amount:
		SignalBus.game_won.emit();

func save_fight():
		UserData.fight_save.update(
		day_number, 
		current_phase,
		MainTilemap.instance.get_tiles_for_save(),
		TileCardFactory.instance.get_cards_for_save(),
		MonsterFactory.instance.monsters.keys(),
		MonsterFactory.instance.breaches,
		BeaconManager.instance.health);

func load_fight():
	var fight_save = UserData.fight_save;
	if !fight_save.is_init(): return;
	
	day_number = fight_save.day;
	current_phase = fight_save.phase;
	TileCardFactory.instance.load_cards(fight_save.cards);
	MonsterFactory.instance.load(fight_save.monsters, fight_save.breaches);
	MainTilemap.instance.load(fight_save.tiles);
	BeaconManager.instance.health = fight_save.beacon_health;
