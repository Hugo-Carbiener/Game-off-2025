extends Control
class_name TileCard

const tile_card_scene: PackedScene = preload("res://scenes/TileCard.tscn");

@export var card_id: String;
@export var card_name : RichTextLabel;
@export var card_count : RichTextLabel;
@export var card_description : RichTextLabel;
@export var card_sprite: TextureRect;

var card_tile_sprite_atlas_coordinates : Vector2i;

static func create_tile_card(_id : String) -> TileCard:
	var tile_card = tile_card_scene.instantiate();
	tile_card.setup(_id);
	return tile_card;

func _ready():
	print_debug('raidi')
	SignalBus.cards_amount_updated.connect(_on_cards_amount_updated);

func setup(_id : String) :
	var tile_data = TileDataManager.tile_dictionnary[_id];
	card_id = _id;
	card_name.text = tile_data.name;
	card_description.text = tile_data.description;
	card_sprite.texture.region = Rect2(tile_data.atlas_texture_coordinates.x, tile_data.atlas_texture_coordinates.y , TileDataManager.tile_size.x, TileDataManager.tile_size.y);

# Called before a card is destroyed
func on_card_used(tilemap_position : Vector2i):
	var valid_monster_spawns = MainTilemap.instance.get_valid_monster_spawn_positions();
	MonsterFactory.instance.spawn_breach(valid_monster_spawns[randi() % valid_monster_spawns.size()]);
	TileCardFactory.instance.cards_amount[card_id] -= 1;
	TileCardFactory.instance.cards_amount.total -= 1;
	
	# destroy if it was the last card
	print_debug(TileCardFactory.instance.cards_amount[card_id])
	if (TileCardFactory.instance.cards_amount[card_id] == 0):
		queue_free();
		pass
	
	# If hand is empty, next phase
	if TileCardFactory.instance.cards_amount.total == 0:
		ShockWave.instance.execute_large_shockwave(MainTilemap.instance.tilemap_to_viewport(Vector2i.ZERO));
		GameLoop.start_phase(GameLoop.get_next_phase());
	else :
		await ShockWave.instance.execute_small_shockwave(MainTilemap.instance.tilemap_to_viewport(tilemap_position));
	

func _on_cards_amount_updated():
	print_debug('signal', card_id, TileCardFactory.instance.cards_amount[card_id]);
	card_count.text = str(TileCardFactory.instance.cards_amount[card_id]);
