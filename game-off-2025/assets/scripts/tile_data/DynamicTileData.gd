class_name DynamicTileData

# constants
var targetted_by : Array[Vector2i];

# temporary boosts
var damage_boost : int = 0;
var damage_multiplier : int = 1;
var range_boost : int = 0;
var previous_evolutions : Array[String];
var base_tile : String = "";

func on_resolution_end():
	damage_boost = 0;
	damage_multiplier = 1;
	range_boost = 0;
	previous_evolutions.clear();
	base_tile = "";

func reset_boosts():
	pass;
