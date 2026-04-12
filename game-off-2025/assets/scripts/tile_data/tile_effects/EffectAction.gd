@abstract class_name EffectAction

var tile_effect : TileEffect;

func _init(_tile_effect : TileEffect):
	tile_effect = _tile_effect;

@abstract func execute(tile_position : Vector2i, tile_data : CustomTileData);
@abstract func get_description() -> String;
