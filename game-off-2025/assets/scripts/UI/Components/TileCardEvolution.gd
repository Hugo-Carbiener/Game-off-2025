extends Control
class_name TileCardEvolution

const tile_card_evolution_scene: PackedScene = preload("res://scenes/components/TileCardEvolution.tscn");

@export_group("Components")
@export var frame_button : TextureButton;
@export var evolution_icon : TextureRect;

var tile_id : String;
var on_click : Callable;

static func create_tile_card_evolution(tile_data : CustomTileData) -> TileCardEvolution:
	var tile_card_evolution = tile_card_evolution_scene.instantiate();
	tile_card_evolution.setup(tile_data);
	return tile_card_evolution;

func setup(tile_data : CustomTileData) :
	tile_id = tile_data.id;
	evolution_icon.texture = evolution_icon.texture.duplicate();
	var evolution_tile_data = tile_data if TileDataManager.instance.known_evolution.has(tile_data.id) else TileDataManager.instance.tile_dictionnary["unknown"];
	evolution_icon.texture.region = Rect2(evolution_tile_data.atlas_texture_coordinates.x, evolution_tile_data.atlas_texture_coordinates.y , TileDataManager.instance.tile_size.x, TileDataManager.instance.tile_size.y);
	frame_button.disabled = true;

func setup_color(color: Color):
	frame_button.self_modulate = color;

func init_buttons(_on_click : Callable):
	if TileDataManager.instance.known_evolution.has(tile_id):
		frame_button.button_up.connect(_on_click.bind(tile_id));
		frame_button.disabled = false;

func update():
	if !TileDataManager.instance.known_evolution.has(tile_id): return;
	
	var tile_data = TileDataManager.instance.tile_dictionnary[tile_id];
	if tile_data == null: return;
	
	evolution_icon.texture.region = Rect2(tile_data.atlas_texture_coordinates.x, tile_data.atlas_texture_coordinates.y , TileDataManager.instance.tile_size.x, TileDataManager.instance.tile_size.y);
