extends Control
class_name TileCard

const tile_card_scene: PackedScene = preload("res://scenes/TileCard.tscn");

var card_id : String;
@export var card_overlay : TextureRect;
@export var card_count_overlay : TextureRect;
@export var card_count : Label;
@export var card_name : Label;
@export var card_sprite : TextureRect;
@export var card_icons : HBoxContainer;
@export var card_description : Label;

var card_tile_sprite_atlas_coordinates : Vector2i;

static func create_tile_card(_id : String) -> TileCard:
	var tile_card = tile_card_scene.instantiate();
	tile_card.setup(_id);
	return tile_card;

func setup(_id : String) :
	SignalBus.cards_amount_updated.connect(_on_cards_amount_updated);
	var tile_data = TileDataManager.tile_dictionnary[_id];
	card_id = _id;
	card_name.text = tile_data.name;
	card_description.text = tile_data.description;
	card_sprite.texture.region = Rect2(tile_data.atlas_texture_coordinates.x, tile_data.atlas_texture_coordinates.y , TileDataManager.tile_size.x, TileDataManager.tile_size.y);
	init_icons(tile_data);
	init_color(tile_data.color);

func init_color(color : Color) :
	card_name.label_settings = card_name.label_settings.duplicate();
	card_name.label_settings.font_color = color;
	card_description.label_settings = 	card_description.label_settings.duplicate();
	card_description.label_settings.font_color = color;
	
	card_overlay.modulate = color;
	card_count_overlay.modulate = color;
	for card_icon in card_icons.get_children():
		card_icon.modulate = color;

func init_icons(tile_data : CustomTileData) :
	var tile_damage_key = TileDataManager.tile_damages.find_key(tile_data.damage);
	var tile_fatigue_key = TileDataManager.tile_fatigues.find_key(tile_data.fatigue);
	if tile_damage_key != "none":
		var icon = TextureRect.new();
		icon.texture = Constants.damage_icons[tile_damage_key];
		card_icons.add_child(icon);
	if tile_fatigue_key != "none":
		var icon = TextureRect.new();
		icon.texture = Constants.fatigue_icons[tile_fatigue_key];
		card_icons.add_child(icon);

# Called before a card is destroyed
func on_card_used(tilemap_position : Vector2i):
	# var valid_monster_spawns = MainTilemap.instance.get_valid_monster_spawn_positions();
	# MonsterFactory.instance.spawn_breach(valid_monster_spawns[randi() % valid_monster_spawns.size()]);
	TileCardFactory.instance.cards_amount[card_id] -= 1;
	TileCardFactory.instance.cards_amount.total -= 1;
	_on_cards_amount_updated();
	
	# destroy if it was the last card
	if (TileCardFactory.instance.cards_amount[card_id] == 0):
		TileCardFactory.instance.free_card_slot(card_id);
	
	BeaconManager.instance.beacon_tile_placed.emit();
	
	# If hand is empty, next phase
	if TileCardFactory.instance.cards_amount.total == 0:
		ShockWave.instance.execute_large_shockwave(MainTilemap.instance.tilemap_to_viewport(Vector2i.ZERO));
		GameLoop.start_phase(GameLoop.get_next_phase());
	else :
		await ShockWave.instance.execute_small_shockwave(MainTilemap.instance.tilemap_to_viewport(tilemap_position));

func on_card_reroll():
	if TileCardFactory.instance.reroll_left == 0:
		return;
		
	TileCardFactory.instance.reroll_left -= 1;
	SignalBus.reroll_amount_updated.emit(TileCardFactory.instance.reroll_left);
	TileCardFactory.instance.cards_amount[card_id] -= 1;
	TileCardFactory.instance.cards_amount.total -= 1;
	_on_cards_amount_updated();
	# destroy if it was the last card
	if (TileCardFactory.instance.cards_amount[card_id] == 0):
		queue_free();
	
	TileCardFactory.instance.draw_random_card();

func _on_cards_amount_updated():
	card_count.text = "x" + str(TileCardFactory.instance.cards_amount[card_id]);
