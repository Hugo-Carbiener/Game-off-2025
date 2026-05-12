class_name Breach

var tilemap_position: Vector2i;
var turn_delay : int;
var age : int;
var instability : int;
var target_cells : Array[Vector2i];

func _init(_tilemap_position : Vector2i, _turn_delay : int):
	self.tilemap_position = _tilemap_position;
	self.turn_delay = _turn_delay;
	self.age = 0;
	await MonsterFactory.instance.breach_transition(tilemap_position, true);
	destroy_tiles_around();
	select_tiles_around();

func update_breach():
	age += 1;
	if !is_mature() and age >= Constants.breach_setup_delay:
		await mature_tile();
		return;

func mature_tile():
	await MonsterFactory.instance.breach_transition(tilemap_position, false);
	var breach_tile_data = TileDataManager.tile_dictionnary.get("large-breach");
	MonsterFactory.instance.place_tile(tilemap_position, breach_tile_data);
	gain_instability(Constants.breach_starting_instability);

func is_mature() -> bool:
	return age > Constants.breach_setup_delay;

func gain_instability(instability_amount : int):
	instability = min(max(0, instability + instability_amount), Constants.breach_max_instability);
	SignalBus.breach_instability_changed.emit(tilemap_position, instability);
	
	# dispatch
	var text = ("+" if instability_amount > 0 else "-") + str(abs(instability_amount));
	var text_damage = MonsterTextDamage.create_animated_monster_text_damage(text, TileDataManager.burst_icon_small, true);
	text_damage.position = MonsterFactory.instance.map_to_local(tilemap_position);
	MonsterFactory.instance.add_child(text_damage);
	
	if instability == 0:
		seal_breach();
	if instability == Constants.breach_max_instability:
		burst_breach();

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
	target_cells = valid_cells.slice(0, Constants.breach_target_cells_amount);

func seal_breach():
	pass;

func burst_breach():
	pass;
