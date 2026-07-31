extends Node2D
class_name GameLoop

enum PHASES {SETUP, HARVEST, PLAY, RESOLUTION}
static var phase_start_sequences = {
	PHASES.SETUP : Callable(setup_phase),
	PHASES.HARVEST : Callable(harvest_phase),
	PHASES.PLAY : Callable(play_phase),
	PHASES.RESOLUTION : Callable(resolution_phase)
}
static var current_phase : PHASES;
static var current_day : int;
static var max_area_instability : int;
static var area_instability : int;

func _ready() -> void:
	current_phase = PHASES.SETUP;
	current_day = 0;
	max_area_instability = Constants.base_breach_amount * Constants.breach_max_instability;
	area_instability = max_area_instability;
	SignalBus.play_phase_ended.connect(end_turn);
	SignalBus.game_saving.connect(save_fight); 
	SignalBus.tile_placed.connect(on_tile_placed);
	AudioUtils.fade_in(AudioUtils.play_music(AudioUtils.musics[AudioUtils.MUSICS.START]), 2);
	
	await get_tree().process_frame #wait the first UI layout pass
	start_game();

func start_game():
	load_fight();
	start_phase(current_phase);

static func get_next_phase() -> int:
	return PHASES.values()[(current_phase + 1) % PHASES.size()];

static func start_phase(phase: PHASES):
	current_phase = phase;
	phase_start_sequences.get(phase).call();

static func setup_phase():
	UserSettings.are_input_blocked = true;
	current_day += 1;
	SignalBus.setup_phase_started.emit();
	await GameUI.instance.display_phase_title(current_phase);
	await HeaderWindow.instance.on_setup();
	await MonsterFactory.instance.on_setup();
	await DrawPile.instance.draw_hand();
		
	start_phase(get_next_phase());

static func harvest_phase():
	UserSettings.are_input_blocked = true;
	#SignalBus.harvest_phase_started.emit();

	start_phase(get_next_phase());

static func play_phase():
	SignalBus.play_phase_started.emit();
	await GameUI.instance.display_phase_title(current_phase);
	UserSettings.are_input_blocked = false;

static func resolution_phase():
	UserSettings.are_input_blocked = true;
	
	if need_resolution_phase():
		TileSelector.instance.unselect_tile();
		SignalBus.resolution_phase_started.emit();
		await GameUI.instance.display_phase_title(current_phase);
		await MainCamera.zoom_transition(MainTilemap.instance.position, Vector2i.ONE * 2);
		MainTilemap.instance.execute_all_tile_effects(TileDataManager.TRIGGERS.ON_RESOLUTION_START);
		await MonsterFactory.instance.on_resolution();
		MainTilemap.instance.execute_all_tile_effects(TileDataManager.TRIGGERS.ON_RESOLUTION_END);
		BeaconManager.instance.on_resolution_end();
		await MainCamera.zoom_transition(Vector2i.ZERO, Vector2i.ONE);

	start_phase(get_next_phase());

func end_turn():
	start_phase(get_next_phase());

func on_tile_placed(tile_amount : int):
	if tile_amount >= TileDataManager.world_tile_amount:
		SignalBus.game_won.emit();

static func is_breach_spawn_day(day : int) -> bool:
	return day % Constants.breach_spawn_step ==  Constants.first_breach_spawn_round;

static func need_resolution_phase() -> bool:
	if MonsterFactory.breaches.is_empty(): return false;
	
	for breach in MonsterFactory.breaches.values():
		if breach.is_mature(): return true;
	return false;

func save_fight():
		UserData.fight_save.update(
		current_day, 
		current_phase,
		MainTilemap.instance.get_tiles_for_save(),
		HandPile.instance.get_cards_for_save(),
		DrawPile.instance.get_cards_for_save(),
		DiscardPile.instance.get_cards_for_save(),
		MonsterFactory.instance.monsters.keys(),
		{}, #TODO : save breaches
		BeaconManager.instance.health);

func load_fight():
	var fight_save = UserData.fight_save;
	if !fight_save.is_init(): return;
	
	current_day = fight_save.day;
	current_phase = fight_save.phase;
	HandPile.instance.load_pile(fight_save.hand_cards);
	DrawPile.instance.load_pile(fight_save.draw_cards);
	DiscardPile.instance.load_pile(fight_save.discard_cards);
	MonsterFactory.instance.load(fight_save.monsters, fight_save.breaches);
	MainTilemap.instance.load(fight_save.tiles);
	BeaconManager.instance.health = fight_save.beacon_health;
