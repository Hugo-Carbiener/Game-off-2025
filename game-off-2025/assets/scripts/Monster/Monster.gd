class_name Monster

var health : int;
var tilemap_position : Vector2i;

func _init(_health: int, _tilemap_position: Vector2i):
	self.health = _health;
	self.tilemap_position = _tilemap_position;

func on_death():
	TileCardFactory.instance.draw_random_card();
