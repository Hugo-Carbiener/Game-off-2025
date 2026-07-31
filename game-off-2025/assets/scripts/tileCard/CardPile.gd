@abstract class_name CardPile extends Control

@export var pile_size_label : Label;
@export_group("Signals")
@export var card_added_signal : String;
@export var card_removed_signal : String;

var cards : Array[String];

func remove_card(tile_card : TileCard):
	var card_id = tile_card.card_id;
	if !cards.has(card_id):
		printerr("Attempted to draw card that is not in draw pile: " + card_id);
		return;
	
	cards.erase(card_id);
	if !card_removed_signal.is_empty() and SignalBus.has_signal(card_removed_signal):
		SignalBus.emit_signal(card_removed_signal, tile_card);
	update_card_amount();

func add_card(tile_card : TileCard):
	var card_id = tile_card.card_id;
	cards.append(card_id);
	if !card_added_signal.is_empty() and SignalBus.has_signal(card_added_signal):
		SignalBus.emit_signal(card_added_signal, tile_card);
	update_card_amount();

func get_pile_size() -> int:
	return cards.size();

func update_card_amount():
	pile_size_label.text = str(cards.size());

func get_cards_for_save() -> Array[String]:
	var cards_for_save : Array[String];
	for card in cards:
		cards_for_save.append(card);
	return cards_for_save;

func load_pile(_cards : Array[String]):
	for card in _cards:
		cards.append(card);
