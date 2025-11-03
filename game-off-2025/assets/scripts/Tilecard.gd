extends Control
class_name TileCard

const tile_card_scene: PackedScene = preload("res://scenes/TileCard.tscn");

@export var card_name : RichTextLabel;
@export var card_description : RichTextLabel;
@export var card_sprite: TextureRect;
var card_tile_sprite_atlas_coordinates : Vector2i;

## tmp
var card_names = ["river", "hill", "grove", "plain"];
var card_sprite_atlas_coords = [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0)];
var card_descriptions = ["toto", "tutu", "tata"];

static func create_tile_card() -> TileCard:
	var tile_card = tile_card_scene.instantiate();
	tile_card.setup();
	return tile_card;

func setup() :
	card_name.text = card_names[randi() % card_names.size()];
	card_description.text = card_descriptions[randi() % card_descriptions.size()];
	var card_sprite_texture : AtlasTexture = card_sprite.texture;
	card_tile_sprite_atlas_coordinates = card_sprite_atlas_coords[randi() % card_sprite_atlas_coords.size()];
	var atlas_coords = card_tile_sprite_atlas_coordinates * 16;
	card_sprite_texture.region = Rect2(atlas_coords.x, atlas_coords.y , 16, 16);
