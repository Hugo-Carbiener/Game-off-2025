extends Control
class_name TileCardFactory

static var instance : TileCardFactory;
var card_amount = 0;

func _ready() -> void:
	if instance == null:
		instance = self;

func generate_random_card() :
	var tile_card = TileCard.create_random_tile_card();
	add_child(tile_card);
	card_amount += 1;
