extends Control
class_name TileCard

const tile_card_scene: PackedScene = preload("res://scenes/TileCard.tscn");

@export var card_name : RichTextLabel;
@export var card_description : RichTextLabel;
@export var card_sprite: TextureRect;
var card_tile_sprite_atlas_coordinates : Vector2i;

static func create_random_tile_card():
	return create_tile_card(TileDataManager.playable_tiles[randi() % TileDataManager.playable_tiles.size()]);

static func create_tile_card(_name : String) -> TileCard:
	var tile_card = tile_card_scene.instantiate();
	tile_card.setup(_name);
	return tile_card;

func setup(_name : String) :
	var tile_data = TileDataManager.tile_dictionnary[_name.to_lower()];
	card_name.text = tile_data.name;
	card_description.text = tile_data.description;
	card_sprite.texture.region = Rect2(tile_data.atlas_texture_coordinates.x, tile_data.atlas_texture_coordinates.y , 16, 16);
