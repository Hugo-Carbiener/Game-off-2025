@abstract class_name TileRequirement

@abstract func is_met(tilemap_position : Vector2i) -> bool;
@abstract func has_requirement() -> bool;
@abstract func get_requirement() -> Dictionary[Vector2i, String];
