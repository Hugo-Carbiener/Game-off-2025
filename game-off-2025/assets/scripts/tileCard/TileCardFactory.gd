extends Control
class_name TileCardFactory

static var instance : TileCardFactory;

var cards : Array[TileCard];
var reroll_left: int = 0;

func _ready() -> void:
	if instance == null:
		instance = self;
	
	SignalBus.card_discarded.connect(on_card_discarded)
	SignalBus.reroll_amount_updated.emit(reroll_left);

func list_children():
	return get_children();

func draw_random_card() :
	var index = randi() % TileDataManager.playable_tiles.size();
	var random_id: String = TileDataManager.playable_tiles[index];
	draw_card(random_id);

func draw_card(tile_id : String):
	var tile_card = TileCard.create_tile_card(tile_id);
	cards.append(tile_card);
	add_child(tile_card);

func on_card_discarded(tilecard : TileCard):
	var tilecard_index = cards.find(tilecard);
	if tilecard_index == -1: 
		return;
	cards.pop_at(tilecard_index);

func draw_hand():
	reroll_left = GameLoop.day_number;
	SignalBus.reroll_amount_updated.emit(reroll_left);
	
	for i in Constants.base_card_per_round:
		TileCardFactory.instance.draw_random_card();

func update_tile_card_evolutions():
	for tile_card in cards:
		tile_card.update_evolutions();

func load_cards(_cards : Array[String]):
	for tile_id in _cards:
		if !TileDataManager.playable_tiles.has(tile_id): continue;
		
		draw_card(tile_id);

func get_cards_for_save() -> Array[String]:
	var cards_for_save : Array[String];
	for tilecard in cards:
		cards_for_save.append(tilecard.card_id);
	return cards_for_save;
