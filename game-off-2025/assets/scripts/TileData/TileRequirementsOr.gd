extends TileRequirement
class_name TileRequirementsOr

var requirements : Array[TileRequirement];

func is_met(tilemap_position : Vector2i) -> bool:
	for requirement in requirements:
		if requirement.is_met(tilemap_position):
			return true;
	return false;

func has_requirement() -> bool:
	return requirements != null and !requirements.is_empty();

func get_requirement() -> Dictionary[Vector2i, String]:
	return requirements.pick_random().get_requirement();
