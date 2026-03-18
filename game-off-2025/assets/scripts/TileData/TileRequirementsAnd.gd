extends TileRequirement
class_name TileRequirementsAnd

var requirements : Array[TileRequirement];

func is_met(tilemap_position : Vector2i) -> bool:
	for requirement in requirements:
		if !requirement.is_met(tilemap_position):
			return false;
	return true;

func has_requirement() -> bool:
	return requirements != null and !requirements.is_empty();

func get_requirement() -> Dictionary[Vector2i, String]:
	var res : Dictionary[Vector2i, String];
	for requirement in requirements:
		res.merge(requirement.get_requirement());
	return res;
