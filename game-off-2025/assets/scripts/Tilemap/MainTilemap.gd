extends TilemapManager
class_name MainTilemap

static var instance : MainTilemap;
@export var beacon_sprite : Sprite2D;
@export_group("Evolution transition")
@export var evolution_transition_duration : float;
@export var evolution_from_tile_sprite : Sprite2D;
@export var evolution_to_tile_sprite : Sprite2D;

func _ready() -> void:
	super();
	if instance == null:
		instance = self;
	init_world();

func place_tile(tile_position : Vector2i, tile : CustomTileData, force : bool = false) -> bool :
	var monster = MonsterFactory.monsters.get(tile_position);
	if  monster != null: return false;
	
	var placed_tile = super(tile_position, tile, force);
	if !placed_tile: return false; 

	SignalBus.tile_placed.emit(tiles.size());
	var breach = MonsterFactory.breaches.get(tile_position);
	if breach != null:
		breach.cover();
	
	await check_for_evolution(tile_position);
	# update direct neighbors to check for an evolution
	for neighbor_offset in get_neighbor_tile_coordinate_offset_within_range(1):
		if !has_tile_at(tile_position + neighbor_offset): continue;
		
		await check_for_evolution(tile_position + neighbor_offset);
	return true;

func is_valid_cell(coordinates : Vector2) -> bool:
	if !cell_distance(coordinates, Vector2.ZERO) <= Constants.beacon_range:
		return false;
	
	if has_tile_at(coordinates) : return false;
	
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
	place_tile(Vector2.ZERO, TileDataManager.instance.tile_dictionnary["beacon"], true);
	beacon_sprite.position = map_to_local(Vector2i.ZERO);

func check_for_evolution(tile_position : Vector2i):
	var tile_data = tiles.get(tile_position);
	if  tile_data == null or tile_data.evolutions.size() == 0 : return;
	
	for evolution in tile_data.evolutions:
		var evolution_tile_data = TileDataManager.instance.tile_dictionnary.get(evolution);
		if evolution_tile_data == null:
			print("Invalid evolution tile key : " + evolution + " for tile " + tile_data.name);
			continue;
		
		if evolution_tile_data.requirement == null or evolution_tile_data.requirement.is_met(tile_position) :
			await evolve_tile(tile_position, tile_data, evolution_tile_data);
			return;

func evolve_tile(tile_position : Vector2i, current_tile : CustomTileData, evolution : CustomTileData):
	clear_tile(tile_position);
	await evolution_transition(tile_position, current_tile, evolution);
	TileDataManager.instance.learn_evolution(evolution);
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

func apply_tile_effects(tilemap_position : Vector2i, monster : Monster, trigger : TileDataManager.TRIGGERS):
	var tile_data = tiles.get(tilemap_position);
	if tile_data == null: return;
	
	if trigger == TileDataManager.TRIGGERS.ON_TILE_ENTER or trigger == TileDataManager.TRIGGERS.ON_TILE_STAY:
		monster.damage(tile_data.damage);
	
	# execute all tile action that matche a trigger
	execute_tile_actions(tile_data, monster, trigger);
	for neighbor_offset in get_neighbor_tile_coordinate_offset_within_range(1):
		# execute all neighbor tile action that match a neighbor trigger
		var neighbor_tile_data = tiles.get(tilemap_position + neighbor_offset);
		if neighbor_tile_data == null: continue;
		execute_tile_actions(neighbor_tile_data, monster, TileDataManager.trigger_to_neighbor_trigger[trigger]);

func execute_tile_actions(tile_data : CustomTileData, monster : Monster, trigger : TileDataManager.TRIGGERS):
	for action in tile_data.actions:
		action.execute(monster, trigger);

func tilemap_to_viewport(tilemap_position : Vector2i) -> Vector2:
	var world_pos = map_to_local(tilemap_position) + global_position/2;
	var camera = get_viewport().get_camera_2d();
	var viewport_coordinates = camera.get_canvas_transform() * world_pos;
	return viewport_coordinates;
