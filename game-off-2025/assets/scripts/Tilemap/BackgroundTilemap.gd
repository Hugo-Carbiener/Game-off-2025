extends TilemapManager
class_name BackgroundTilemap


func _ready() -> void:
	super();
	var _range = range(-1 * Constants.beacon_range, Constants.beacon_range + 1, 1);
	for x in _range:
		for y in _range:
			var coordinates = Vector2(x,y);
			if !is_valid_cell(coordinates): continue;
			place_tile(coordinates, TileDataManager.tile_dictionnary["background"]);
			TileDataManager.world_tile_amount += 1;

func is_valid_cell(coordinates : Vector2) -> bool:
	if !cell_distance(coordinates, Vector2.ZERO) <= Constants.beacon_range:
		return false;
	return true;
