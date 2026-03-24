class_name DynamicTileData

var tile_data : CustomTileData;
var targetted_by : Array[Vector2i];
var damage_boost : int;
var damage_multiplier : int;
var range_boost : int;
var previous_evolutions : Array[String];


func on_evolution(base_tile_id : String):
	previous_evolutions.append(base_tile_id);

func on_devolution(evolved_tile_id : String)
