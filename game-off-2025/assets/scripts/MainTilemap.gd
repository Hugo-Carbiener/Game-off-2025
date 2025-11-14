extends TilemapManager
class_name MainTilemap

static var instance : MainTilemap;

func _ready() -> void:
	super();
	if instance == null:
		instance = self;
	init_world();

func place_tile(tile_position : Vector2i, tile : CustomTileData, force : bool = false) -> bool :
	var monster = MonsterFactory.monsters.get(tile_position);
	if  monster != null: return false;
	
	var breach = MonsterFactory.breaches.get(tile_position);
	if breach != null:
		breach.cover();
	
	var placed_tile = super(tile_position, tile, force);
	if !placed_tile: return false; 
	
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

func init_world():
	place_tile(Vector2.ZERO, TileDataManager.tile_dictionnary["beacon"], true);
	#for x in range(-50 , 51, 1):
		#for y in range(-50, 51, 1):
			#var coords = Vector2(x, y);
			#if x == 0 and y == 0 : 
				#continue;
			#if !is_valid_cell(coords) :
				#continue;
			#var tile_data = TileDataManager.get_random_tile_data(true);
			#set_cell(coords, source_id, tile_data.atlas_coordinates);

func apply_tile_effects(tilemap_position : Vector2i, monster : Monster):
	var tile_data = tiles.get(tilemap_position);
	if tile_data == null: return;
	
	monster.damage(tile_data.damage);
