extends TileRequirement
class_name TileRequirementsOr

var requirements : Array[TileRequirement];

func is_met(tilemap_position : Vector2i) -> bool:
	for requirement in requirements:
		if requirement.is_met(tilemap_position):
			return true;
	return false;
