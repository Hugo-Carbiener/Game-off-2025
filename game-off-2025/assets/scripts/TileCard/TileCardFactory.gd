extends Control
class_name TileCardFactory

var damage_icons : Dictionary[String, ImageTexture] = {
	"low" = ImageTexture.create_from_image(Image.load_from_file("res://assets/sprites/UI_card_icon_low_damage.png")),
	"medium" = ImageTexture.create_from_image(Image.load_from_file("res://assets/sprites/UI_card_icon_medium_damage.png")),
	"high" = ImageTexture.create_from_image(Image.load_from_file("res://assets/sprites/UI_card_icon_high_damage.png"))
}
var fatigue_icons : Dictionary[String, ImageTexture] = {
	"low" = ImageTexture.create_from_image(Image.load_from_file("res://assets/sprites/UI_card_icon_low_fatigue.png")),
	"medium" = ImageTexture.create_from_image(Image.load_from_file("res://assets/sprites/UI_card_icon_medium_fatigue.png")),
	"high" = ImageTexture.create_from_image(Image.load_from_file("res://assets/sprites/UI_card_icon_high_fatigue.png"))
}
static var instance : TileCardFactory;
var cards_amount = {"total": 0};

func _ready() -> void:
	if instance == null:
		instance = self;
	
	# init count with all playable card names
	for id in TileDataManager.playable_tiles:
		cards_amount[id] = 0;

func list_children():
	return get_children();

func draw_random_card() :
	var random_id: String = TileDataManager.playable_tiles[randi() % TileDataManager.playable_tiles.size()];
	
	# if card already in hand, stop here
	if TileCardFactory.instance.cards_amount[random_id] == 0:
		var tile_card = TileCard.create_tile_card(random_id);
		add_child(tile_card);
	
	cards_amount[random_id] += 1; 
	cards_amount.total += 1;
	
	SignalBus.cards_amount_updated.emit();

func draw_hand():
	for i in Constants.base_card_per_round:
		TileCardFactory.instance.draw_random_card();
