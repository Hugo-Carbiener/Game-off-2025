class_name TileCost 

var natural_cost : int;
var mineral_cost : int;
var artificial_cost : int;

func _init(_natural_cost : int, _mineral_cost : int, _artificial_cost : int) -> void:
	self.natural_cost = _natural_cost;
	self.mineral_cost = _mineral_cost;
	self.artificial_cost = _artificial_cost;

func has_cost() -> bool:
	return natural_cost > 0 or mineral_cost > 0 or artificial_cost > 0;

func to_dictionary() -> Dictionary[TileDataManager.BIOMES, int]:
	return {
			TileDataManager.BIOMES.NATURAL : natural_cost,
		TileDataManager.BIOMES.MINERAL : mineral_cost,
		TileDataManager.BIOMES.ARTIFICIAL : artificial_cost
	};
