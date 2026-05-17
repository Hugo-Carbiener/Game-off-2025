extends TilemapManager
class_name MainTilemap

static var instance : MainTilemap;
@export var beacon_sprite : Sprite2D;
@export var tile_feedback_sprite : Sprite2D;
@export_group("Evolution transition")
@export var evolution_transition_duration : float;
@export var evolution_from_tile_sprite : Sprite2D;
@export var evolution_to_tile_sprite : Sprite2D;

var tiles_dynamic_data : Dictionary[Vector2i, DynamicTileData];
var is_evolving_tile = false;

func _ready() -> void:
	super();
	if instance == null:
		instance = self;
	init_world();

func place_tile(tile_position : Vector2i, tile : CustomTileData, force : bool = false) -> bool :
	if MonsterFactory.monsters.has(tile_position): return false;
	
	var placed_tile = super(tile_position, tile, force);
	if !placed_tile: return false; 

	SignalBus.tile_placed.emit(tiles.size());
	
	if !tiles_dynamic_data.has(tile_position):
		tiles_dynamic_data.set(tile_position, DynamicTileData.new());
	else: 
		tiles_dynamic_data[tile_position].reset_boosts();
	
	update_targetted_tiles(tile_position);
	update_targetting_tiles(tile_position);
	execute_tile_effects(TileDataManager.TRIGGERS.ON_TILE_PLACED, tile_position);
	
	await check_for_evolution(tile_position);
	# update direct neighbors to check for an evolution
	for neighbor_offset in get_neighbor_tile_coordinate_offset_within_range(1):
		if !has_tile_at(tile_position + neighbor_offset): continue;
		
		await check_for_evolution(tile_position + neighbor_offset);
	
	return true;

func destroy_tile(tilemap_position : Vector2i):
	if !tiles.has(tilemap_position) or tilemap_position == Vector2i.ZERO: return;
	
	execute_ranged_tile_effects(TileDataManager.TRIGGERS.ON_TILE_DESTROYED, tilemap_position);
	clear_targetted_tiles(tilemap_position);
	clear_tile(tilemap_position);

func clear_tile(tile_position : Vector2i):
	super(tile_position);
	tiles_dynamic_data.erase(tile_position);

func is_valid_cell(coordinates : Vector2i) -> bool:
	if !cell_distance(coordinates, Vector2.ZERO) <= Constants.beacon_range:
		return false;
	
	if has_tile_at(coordinates) \
		or MonsterFactory.monsters.has(coordinates) \
		or MonsterFactory.breaches.has(coordinates): return false;
	
	var has_neighbor = false;
	for neighbor_coordinates in get_surrounding_cells(coordinates):
		if has_tile_at(neighbor_coordinates): 
			has_neighbor = true;
			break;
	
	return has_neighbor;

func get_valid_cells() -> Array[Vector2i] :
	var result : Array[Vector2i];
	for cell in get_used_cells():
		for neighbor_offset in get_neighbor_tile_coordinate_offset_within_range(1):
			var neighbor_coordinates = cell + neighbor_offset;
			if is_valid_cell(neighbor_coordinates):
				result.append(neighbor_coordinates);
	return result;

func init_world():
	place_tile(Vector2.ZERO, TileDataManager.tile_dictionnary["beacon"], true);
	beacon_sprite.position = map_to_local(Vector2i.ZERO);

func check_for_evolution(tile_position : Vector2i):
	var tile_data = tiles.get(tile_position);
	if  tile_data == null or tile_data.evolutions.size() == 0 : return;
	
	for evolution in tile_data.evolutions:
		var evolution_tile_data = TileDataManager.tile_dictionnary.get(evolution);
		if evolution_tile_data == null:
			printerr("Invalid evolution tile key : " + evolution + " for tile " + tile_data.name);
			continue;
		
		if evolution_tile_data.requirement == null or evolution_tile_data.requirement.is_met(tile_position) :
			await evolve_tile(tile_position, tile_data, evolution_tile_data, true);
			return;

func evolve_tile(tile_position : Vector2i, current_tile : CustomTileData, evolution : CustomTileData, is_true_evolution : bool = false):
	await evolution_transition(tile_position, current_tile, evolution);
	if is_true_evolution:
		var dynamic_tile_data = tiles_dynamic_data[tile_position];
		dynamic_tile_data.previous_evolutions.append(current_tile.id);
	TileDataManager.learn_evolution(evolution);
	place_tile(tile_position, evolution, true);

func init_evolution_transition(tile_position : Vector2i, from_tile : CustomTileData, to_tile : CustomTileData):
	evolution_from_tile_sprite.position = map_to_local(tile_position);
	evolution_from_tile_sprite.texture.region = from_tile.get_texture_region();
	evolution_from_tile_sprite.visible = true;
	evolution_from_tile_sprite.modulate = Color(1, 1, 1, 1);
	evolution_to_tile_sprite.position = map_to_local(tile_position);
	evolution_to_tile_sprite.texture.region = to_tile.get_texture_region();
	evolution_to_tile_sprite.visible = true;
	evolution_to_tile_sprite.modulate = Color(10, 10, 10, 0);

func evolution_transition(tile_position : Vector2i, from_tile : CustomTileData, to_tile : CustomTileData):
	is_evolving_tile = true;
	SignalBus.evolution_started.emit();
	var tween = get_tree().create_tween();
	tween.tween_callback(init_evolution_transition.bind(tile_position, from_tile, to_tile));
	tween.tween_property(evolution_from_tile_sprite, "modulate", Color(10, 10, 10, 1), evolution_transition_duration/3).from(Color(1, 1, 1, 1));
	tween.set_parallel(true);
	tween.tween_property(evolution_from_tile_sprite, "modulate", Color(10, 10, 10, 0), evolution_transition_duration/3).from(Color(10, 10, 10, 1));
	tween.tween_property(evolution_to_tile_sprite, "modulate", Color(10, 10, 10, 1), evolution_transition_duration/3).from(Color(10, 10, 10, 0));
	tween.set_parallel(false);
	tween.tween_property(evolution_to_tile_sprite, "modulate", Color(1, 1, 1, 1), evolution_transition_duration/3).from(Color(10,10,10,1));
	tween.tween_callback(func(): evolution_from_tile_sprite.visible = false);
	tween.tween_callback(func(): evolution_to_tile_sprite.visible = false);
	await tween.finished;
	is_evolving_tile = false;
	SignalBus.evolution_finished.emit();

func is_currently_evolving_tile() -> bool:
	return is_evolving_tile;

# Updates the targetted_by field of all tiles in the range of the current tile
func update_targetted_tiles(tile_position : Vector2i):
	var tile_data = tiles[tile_position];
	if tile_data == null: return;
	
	var offset_coordinates = tile_data.get_cells_in_range();
	if offset_coordinates.size() <= 1 : return;

	for offset_coordinate in offset_coordinates:
		var targetted_coordinates = tile_position + offset_coordinate;
		if offset_coordinate == Vector2i(0,0): continue;
		
		if !tiles_dynamic_data.has(targetted_coordinates):
			tiles_dynamic_data.set(targetted_coordinates, DynamicTileData.new());
		
		var targetted_tile_dynamic_data = tiles_dynamic_data[targetted_coordinates];
		if !targetted_tile_dynamic_data.targetted_by.has(tile_position):
			targetted_tile_dynamic_data.targetted_by.append(tile_position);

func clear_targetted_tiles(tile_position : Vector2i):
	var tile_data = tiles[tile_position];
	if tile_data == null: return;
	
	var offset_coordinates = tile_data.get_cells_in_range();
	if offset_coordinates.size() <= 1 : return;
	
	for offset_coordinate in offset_coordinates:
		var targetted_coordinates = tile_position + offset_coordinate;
		if offset_coordinate == Vector2i(0,0): continue;
		
		if !tiles_dynamic_data.has(targetted_coordinates):
			tiles_dynamic_data.erase(targetted_coordinates);

func update_targetting_tiles(tile_position : Vector2i):
	var dynamic_tile_data = tiles_dynamic_data[tile_position];
	if dynamic_tile_data == null: return;
	
	dynamic_tile_data.targetted_by.clear();
	for target_tile_coordinates in tiles.keys():
		if target_tile_coordinates == tile_position: continue;
		
		var distance = cell_manhattan_distance(tile_position, target_tile_coordinates);
		var target_tile_data = tiles[target_tile_coordinates];
		if distance < target_tile_data.effect_range.min_range or distance > target_tile_data.effect_range.max_range: continue;
		
		dynamic_tile_data.targetted_by.append(target_tile_coordinates);

func apply_tile_damage(tilemap_position : Vector2i, monster : Monster):
	var tile_data = tiles.get(tilemap_position);
	if tile_data == null: return;
	
	if monster != null:
		await bounce_tile(tilemap_position, tile_data);
		await monster.damage(tile_data.damage, tilemap_position);

func apply_tile_breach_damage(tilemap_position : Vector2i, breach : Breach):
	var tile_data = tiles.get(tilemap_position);
	if tile_data == null: return;
	
	if breach != null:
		breach.gain_instability(-1 * tile_data.damage, tilemap_position);
		await bounce_tile(tilemap_position, tile_data);

func apply_ranged_tile_damage(tilemap_position : Vector2i, monster : Monster):
	var tile_data = tiles.get(tilemap_position);
	if tile_data == null: return;
	
	var dynamic_tile_data = tiles_dynamic_data[tilemap_position];
	if dynamic_tile_data == null: return;
	
	for targetting_tile_coordinates in dynamic_tile_data.targetted_by:
		var targetting_tile_data = tiles[targetting_tile_coordinates];
		await bounce_tile(targetting_tile_coordinates, tile_data);
		await monster.damage(targetting_tile_data.damage, targetting_tile_coordinates);

func bounce_tile(tile_position : Vector2i,tile_data : CustomTileData):
	tile_feedback_sprite.texture.region = tile_data.get_texture_region();
	tile_feedback_sprite.position = map_to_local(tile_position);
	tile_feedback_sprite.visible = true;
	hide_tile(tile_position);
	await AnimationUtils.bounce(tile_feedback_sprite, 1.5);
	show_tile(tile_position);
	tile_feedback_sprite.visible = false;

## Execute tile effects for a given trigger
## Returns true if a tile effect was executed
func execute_tile_effects(trigger : TileDataManager.TRIGGERS, tilemap_position : Vector2i):
	if !tiles.has(tilemap_position): return;
	
	var tile_data = tiles[tilemap_position];
	await tile_data.execute_effects(trigger, tilemap_position);

func execute_ranged_tile_effects(trigger : TileDataManager.TRIGGERS, tilemap_position : Vector2i):
	var tile_data = tiles.get(tilemap_position);
	if tile_data == null: return;
	
	var dynamic_tile_data = tiles_dynamic_data[tilemap_position];
	if dynamic_tile_data == null: return;
	
	for targetting_tile_coordinates in dynamic_tile_data.targetted_by:
		await execute_tile_effects(trigger, targetting_tile_coordinates);

func execute_all_tile_effects(trigger : TileDataManager.TRIGGERS):
	for tile_position in tiles.keys():
		var tile_data = tiles[tile_position];
		tile_data.execute_effects(trigger, tile_position);

func tilemap_to_viewport(tilemap_position : Vector2i) -> Vector2:
	var world_pos = map_to_local(tilemap_position) + global_position/2;
	var viewport_coordinates = MainCamera.world_to_viewport(world_pos);
	return viewport_coordinates;

func load(_tiles : Dictionary[Vector2i, String]):
	for tile_position in _tiles.keys():
		var tile_data = TileDataManager.tile_dictionnary[_tiles[tile_position]];
		if tile_data == null: continue;
		
		place_tile(tile_position, tile_data, true);

func get_tiles_for_save() -> Dictionary[Vector2i, String]:
	var _tiles : Dictionary[Vector2i, String];
	for tile_position in tiles.keys():
		_tiles.set(tile_position, tiles[tile_position].id);
	return _tiles;
