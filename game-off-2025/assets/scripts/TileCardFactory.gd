extends Node2D
class_name TileCardFactory

@export var card_hand : HBoxContainer;

static var instance : TileCardFactory;

func _ready() -> void:
	if instance == null : 
		instance = self

func generate_random_card() :
	var tile_card = TileCard.create_random_tile_card();
	card_hand.add_child(tile_card);
