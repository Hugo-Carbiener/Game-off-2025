extends TilemapManager
class_name MainTilemap

static var instance : MainTilemap;
@export var beacon_sprite : Sprite2D;
@export var tile_feedback_sprite : Sprite2D;
@export_group("Evolution transition")
@export var evolution_transition_duration : float;
@export var evolution_from_tile_sprite : Sprite2D;
@export var evolution_to_tile_sprite : Sprite2D;

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
	var breach = MonsterFactory.breaches.get(tile_position);
	if breach != null:
		MonsterFactory.instance.cover_breach(tile_position);
	
	await check_for_evolution(tile_position);
	# update direct neighbors to check for an evolution
	for neighbor_offset in get_neighbor_tile_coordinate_offset_within_range(1):
		if !has_tile_at(tile_position + neighbor_offset): continue;
		
		await check_for_evolution(tile_position + neighbor_offset);
	
	update_targetted_tiles(tile_position);
	return true;

func is_valid_cell(coordinates : Vector2i) -> bool:
	if !cell_distance(coordinates, Vector2.ZERO) <= Constants.beacon_range:
		return false;
	
	if has_tile_at(coordinates) : return false;
	
	if MonsterFactory.monsters.has(coordinates): return false;
	
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
			print("Invalid evolution tile key : " + evolution + " for tile " + tile_data.name);
			continue;
		
		if evolution_tile_data.requirement == null or evolution_tile_data.requirement.is_met(tile_position) :
			await evolve_tile(tile_position, tile_data, evolution_tile_data);
			return;

func evolve_tile(tile_position : Vector2i, current_tile : CustomTileData, evolution : CustomTileData):
	is_evolving_tile = true;
	clear_tile(tile_position);
	await evolution_transition(tile_position, current_tile, evolution);
	TileDataManager.learn_evolution(evolution);
	place_tile(tile_position, evolution, true);
	is_evolving_tile = false;

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
	SignalBus.evolution_finished.emit();
	return;

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
		if !tiles.has(targetted_coordinates): continue;
		
		var targetted_tile = tiles[targetted_coordinates];
		targetted_tile.targetted_by.append(targetted_coordinates);

func apply_tile_effects(tilemap_position : Vector2i, monster : Monster):
	var tile_data = tiles.get(tilemap_position);
	if tile_data == null: return;
	
	monster.damage(tile_data.damage);
	dispatch_tile_damage(tilemap_position, tile_data);
	
	execute_tile_effects(tile_data, monster);
	# TODO: execute tile effects of tiles targetting this cell

func dispatch_tile_damage(tilemap_position : Vector2i, tile_data : CustomTileData):
	tile_feedback_sprite.texture.region = tile_data.get_texture_region();
	tile_feedback_sprite.position = map_to_local(tilemap_position);
	tile_feedback_sprite.visible = true;
	#await AnimationUtils.blink_sprite(tile_feedback_sprite, Color.RED);
	await test(tile_feedback_sprite);
	tile_feedback_sprite.visible = false;

func test(sprite : Sprite2D):
	var tween = get_tree().create_tween();
	tween.tween_property(sprite, "scale", 1.2 * Vector2.ONE, 0.1);
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.1);
	await tween.finished;

func execute_tile_effects(tile_data : CustomTileData, monster : Monster):
	for effect in tile_data.effects:
		effect.execute(monster);

func tilemap_to_viewport(tilemap_position : Vector2i) -> Vector2:
	var world_pos = map_to_local(tilemap_position) + global_position/2;
	var camera = MainCamera.get_camera();
	var viewport_coordinates = camera.get_canvas_transform() * world_pos;
	return viewport_coordinates;

func get_tilemap_hover_signals() -> Array[Signal]:
	return [SignalBus.tile_hovered_in, SignalBus.tile_hovered_out];

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
