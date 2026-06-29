class_name Breach extends AnimatedSprite2D

static var breach_scene : PackedScene = preload("res://scenes/elements/Breach.tscn");

const SPAWN_BREACH_SPRITE_KEY = "spawn";
const SMALL_BREACH_SPRITE_KEY = "small-breach";
const SMALL_TO_LARGE_SPRITE_KEY = "small-to-large";
const LARGE_BREACH_SPRITE_KEY = "large-breach";
const SEALED_BREACH_SPRITE_KEY = "sealed-breach";

@export_group("Intent variables")
@export var intent : Control;
@export var effect_preview : EffectPreview;
@export var intent_declaration_duration : float;
@export var intent_vertical_offset : int;

var tilemap_position: Vector2i;
var turn_delay : int;
var breach_data : BreachData;
var age : int;
var mature : bool;
var sealed : bool;
var instability : int;
var weak_points : Array[Vector2i];
var has_intent : bool = false;

static func create_breach(_tilemap_position : Vector2i, _turn_delay : int, _breach_data : BreachData, parent : CanvasItem) -> Breach:
	var breach = breach_scene.instantiate();
	await breach.setup(_tilemap_position, _turn_delay, _breach_data, parent);
	return breach;

func setup(_tilemap_position : Vector2i, _turn_delay : int, _breach_data : BreachData, parent : CanvasItem):
	self.tilemap_position = _tilemap_position;
	self.turn_delay = _turn_delay;
	self.breach_data = _breach_data;
	modulate = TileDataManager.biome_colors[_breach_data.biome];
	self.age = 0;
	self.mature = false;
	intent.modulate.a = 0;
	position = MonsterFactory.instance.map_to_local(tilemap_position);
	parent.add_child(self);
	await spawn_tile();
	animation = SMALL_BREACH_SPRITE_KEY;
	AnimationUtils.make_float(intent, Constants.default_transition_duration, 2);
	SignalBus.tile_selected.connect(on_tile_selected);
	SignalBus.tile_unselected.connect(on_tile_unselected);
	
	destroy_tiles_around();
	select_tiles_around();

func spawn_tile():
	play(SPAWN_BREACH_SPRITE_KEY);
	await animation_finished;

func update_breach():
	age += 1;
	if !is_mature() and age > Constants.breach_setup_delay:
		mature_breach();
		return;
	
	if is_mature():
		await set_intent();

func set_intent():
	if breach_data.effects == null: 
		has_intent = false;
		printerr("No effects set for breach " + breach_data.name);
		return;
	var effect = get_intent_effect();
	effect_preview.setup(effect);
	has_intent = true;
	
	var tween = get_tree().create_tween();
	tween.tween_callback(toggle_intent.bind(true));
	tween.tween_interval(intent_declaration_duration);
	tween.tween_callback(toggle_intent.bind(false));
	await tween.finished;

func get_intent_effect() -> TileEffect:
	return breach_data.effects[(age - 1) % breach_data.effects.size()];

func get_breach_texture_region() -> Rect2:
	return TileDataManager.tile_dictionnary[LARGE_BREACH_SPRITE_KEY if is_mature() else SMALL_BREACH_SPRITE_KEY].get_texture_region();

func apply_tile_interactions():
	# All cells targetting the breach
	var targetting_cells : Array[Vector2i] = weak_points.duplicate();
	if MainTilemap.instance.tiles_dynamic_data.has(tilemap_position):
		weak_points.append_array(MainTilemap.instance.tiles_dynamic_data[tilemap_position].targetted_by);
	
	for target_cell in targetting_cells:
		if !MainTilemap.instance.has_tile_at(target_cell): continue;
		
		await MainTilemap.instance.apply_tile_breach_damage(target_cell, self);
	
	for target_cell in targetting_cells:
		if !MainTilemap.instance.has_tile_at(target_cell): continue;
	
		await MainTilemap.instance.execute_tile_effects(TileDataManager.TRIGGERS.ON_BREACH_INTERACTION, target_cell);

func mature_breach():
	play(SMALL_TO_LARGE_SPRITE_KEY);
	await animation_finished;
	animation = LARGE_BREACH_SPRITE_KEY;
	mature = true;
	gain_instability(Constants.breach_max_instability, tilemap_position);
	check_state();

func seal_breach():
	sealed = true;
	play(SEALED_BREACH_SPRITE_KEY);

func is_mature() -> bool:
	return mature;

func intent_is_displayed() -> bool:
	return intent.modulate.a > 0;

func on_tile_selected(_tilemap_position : Vector2i):
	if tilemap_position != _tilemap_position && intent_is_displayed():
		on_tile_unselected(_tilemap_position);
		return;

	if has_intent && !intent_is_displayed():
		toggle_intent(true);

func on_tile_unselected(_tilemap_position : Vector2i):
	if intent_is_displayed():
		toggle_intent(false);

func toggle_intent(must_be_displayed : bool):
	var margin_from = 0 if must_be_displayed else intent_vertical_offset;
	var margin_to = intent_vertical_offset if must_be_displayed else 0;
	AnimationUtils.animate_integer(
		func(x): intent.add_theme_constant_override("margin_bottom", x),
		margin_from,
		margin_to,
		Constants.default_transition_duration
	);
	await AnimationUtils.fade(intent, int(must_be_displayed), Constants.default_transition_duration/2);

func gain_instability(instability_amount : int, source : Vector2i):
	var effective_amount = min(instability_amount, Constants.breach_max_instability) if instability_amount > 0 else - min(abs(instability_amount), instability);
	instability += effective_amount;
	GameLoop.area_instability = min(GameLoop.area_instability + effective_amount, GameLoop.max_area_instability);
	
	# dispatch
	var text = ("+" if instability_amount > 0 else "-") + str(abs(instability_amount));
	var text_damage = MonsterTextDamage.create_animated_monster_text_damage(text, TileDataManager.burst_icon_small, true);
	text_damage.position = MonsterFactory.instance.map_to_local(source);
	MonsterFactory.instance.add_child(text_damage);
	SignalBus.breach_instability_changed.emit(tilemap_position, instability);

func check_state():
	if instability == 0:
		seal_breach();

func execute_intent():
	if !is_mature() || age == Constants.breach_setup_delay + 1: return;
	
	var effect = get_intent_effect();
	if effect == null: return;
	
	effect.execute(TileDataManager.TRIGGERS.ON_RESOLUTION_START, tilemap_position, null);

func destroy_tiles_around():
	for x in range(-1, 2, 1):
		for y in range(-1, 2, 1):
			if x == 0 and y == 0: continue;
			
			var coordinates = tilemap_position + Vector2i(x, y);
			if coordinates == Vector2i.ZERO: continue;
			
			MainTilemap.instance.destroy_tile(coordinates);

func select_tiles_around():
	var valid_cells : Array[Vector2i];
	for x in range(-1, 2, 1):
		for y in range(-1, 2, 1):
			if x == 0 and y == 0: continue;
			
			var coordinates =  tilemap_position + Vector2i(x, y);
			if coordinates == Vector2i.ZERO: continue;
			
			valid_cells.append(coordinates);
	valid_cells.shuffle();
	weak_points = valid_cells.slice(0, Constants.breach_weak_points_amount);

func get_free_weak_point_position() -> Vector2i:
	var valid_weak_points : Array[Vector2i];
	for weak_point in weak_points:
		if MonsterFactory.monsters.has(weak_point): continue;
		
		valid_weak_points.append(weak_point);
	return valid_weak_points[randi() % valid_weak_points.size()];
