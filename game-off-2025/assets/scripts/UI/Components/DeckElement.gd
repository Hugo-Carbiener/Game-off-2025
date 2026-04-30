class_name DeckElement extends Control

const deck_element_scene : PackedScene = preload("res://scenes/components/DeckElement.tscn");

@export var tile_icon : TextureRect;
@export var draw_rate_text : Label;

static func create_deck_element(tile_id : String, draw_rate : float) -> DeckElement:
	var tile_data = TileDataManager.tile_dictionnary[tile_id];
	if tile_data == null: return null;
	
	var deck_element = deck_element_scene.instantiate();
	deck_element.setup(tile_data, draw_rate);
	return deck_element;

func setup(tile_card : CustomTileData, draw_rate : float):
	tile_icon.texture.region = tile_card.get_texture_region();
	draw_rate_text.text = str(round_to_dec(draw_rate, 3)) + "%";

func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
