class_name Breach

var turn_remaining : int;
var tilemap_position : Vector2i;

func _init(_turn_remaining: int, _tilemap_position: Vector2i):
	self.turn_remaining = _turn_remaining
	self.tilemap_position = _tilemap_position

func update():
	turn_remaining -= 1;
	if turn_remaining == 0:
		MonsterFactory.instance.remove_breach(tilemap_position);
		MonsterFactory.instance.spawn_monster(tilemap_position);
	else:
		MonsterFactory.instance.update_breach_tile(tilemap_position);

func cover():
	MonsterFactory.instance.remove_breach(tilemap_position);
