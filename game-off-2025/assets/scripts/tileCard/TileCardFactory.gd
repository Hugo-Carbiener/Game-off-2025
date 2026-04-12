extends Control
class_name TileCardFactory

static var instance : TileCardFactory;

@export var card_count_label : Label;

var cards : Array[TileCard];
var reroll_left: int = 0;

func _ready() -> void:
	if instance == null:
		instance = self;
	
	SignalBus.card_discarded.connect(on_card_discarded);
	SignalBus.reroll_amount_updated.emit(reroll_left);

func draw_random_card() :
	var index = randi() % TileDataManager.playable_tiles.size();
	var random_id: String = TileDataManager.playable_tiles[index];
	draw_card(random_id);

func draw_card(tile_id : String):
	var tile_card = TileCard.create_tile_card(tile_id);
	cards.append(tile_card);
	SignalBus.card_drawn.emit(tile_card);

func on_card_discarded(tile_card : TileCard):
	update_card_count_label();
	var tilecard_index = cards.find(tile_card);
	if tilecard_index == -1: 
		return;
	cards.pop_at(tilecard_index);

func draw_hand():
	reroll_left = GameLoop.day_number;
	SignalBus.reroll_amount_updated.emit(reroll_left);
	
	var tween = get_tree().create_tween();
	tween.set_loops(Constants.base_card_per_round);
	tween.tween_callback(TileCardFactory.instance.draw_random_card);
	tween.tween_interval(Constants.card_draw_interval);

func update_tile_card_evolutions():
	for tile_card in cards:
		tile_card.update_evolutions();

func update_card_count_label():
	card_count_label.text = str(cards.size()) + " / " + str(Constants.base_card_hand_size);

func load_cards(_cards : Array[String]):
	for tile_id in _cards:
		if !TileDataManager.playable_tiles.has(tile_id): continue;
		
		draw_card(tile_id);

func get_cards_for_save() -> Array[String]:
	var cards_for_save : Array[String];
	for tilecard in cards:
		cards_for_save.append(tilecard.card_id);
	return cards_for_save;

func get_hand_size() -> int:
	return cards.size();
