class_name DeckElement extends Control

const deck_element_scene : PackedScene = preload("res://scenes/components/DeckElement.tscn");

var amount : int;

@export var tile_icon : TextureRect;
@export var amount_text : Label;

static func create_deck_element(tile_id : String, _amount : int) -> DeckElement:
	var tile_data = TileDataManager.tile_dictionnary[tile_id];
	if tile_data == null: return null;
	
	var deck_element = deck_element_scene.instantiate();
	deck_element.setup(tile_data, _amount);
	return deck_element;

func setup(tile_card : CustomTileData, _amount : int):
	tile_icon.texture.region = tile_card.get_texture_region();
	amount = _amount;
	amount_text.text = str(_amount);
	amount_text.pivot_offset = amount_text.size / 2;

func get_amount() -> int:
	return amount;

func update_amount(_amount : int):
	await AnimationUtils.bounce(amount_text, 1.5);
	amount_text.text = str(_amount);
