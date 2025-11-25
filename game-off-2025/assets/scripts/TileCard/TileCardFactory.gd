extends Control
class_name TileCardFactory

var card_slot_model : PackedScene = preload("res://scenes/CardSlot.tscn");

static var instance : TileCardFactory;
var cards_amount = {"total": 0};
var slots_per_card : Dictionary[String, int];
var card_slots : Array[Control];
var card_slot_used_amount = 0;
var reroll_left: int = Constants.reroll_per_turn;

func _ready() -> void:
	if instance == null:
		instance = self;
	init_UI();
	# init count with all playable card names
	for id in TileDataManager.playable_tiles:
		cards_amount[id] = 0;
	
	SignalBus.reroll_amount_updated.emit(reroll_left);

func init_UI():
	if Constants.card_slot_amount < TileDataManager.playable_tiles.size():
		printerr("Warning: not enough slots for all playable cards");
		return;

	for i in range(Constants.card_slot_amount):
		var new_card_slot = card_slot_model.instantiate();
		add_child(new_card_slot);
		card_slots.append(new_card_slot);

func list_children():
	return get_children();

func draw_random_card() :
	var random_id: String = TileDataManager.playable_tiles[randi() % TileDataManager.playable_tiles.size()];
	
	# if card already in hand, stop here
	if TileCardFactory.instance.cards_amount[random_id] == 0:
		fill_card_slot(random_id);
	
	cards_amount[random_id] += 1; 
	cards_amount.total += 1;
	
	SignalBus.cards_amount_updated.emit();

func fill_card_slot(tile_id : String):
	var slot_index = card_slot_used_amount;
	var tile_card = TileCard.create_tile_card(tile_id);
	card_slots[slot_index].add_child(tile_card);
	slots_per_card.set(tile_id, slot_index);
	card_slot_used_amount += 1;

func free_card_slot(tile_id : String):
	if !slots_per_card.has(tile_id): return;
	
	var slot_index = slots_per_card.get(tile_id);
	var card_slot = card_slots[slot_index];
	var card = card_slot.get_children()[1];
	card_slot.remove_child(card);
	slots_per_card.erase(tile_id);
	card.queue_free()
	
	if slot_index + 1 < card_slot_used_amount :
		for further_card_slot_index in range(slot_index + 1 , card_slot_used_amount):
			var further_card_slot = card_slots[further_card_slot_index];
			var further_card = further_card_slot.get_children()[1];
			further_card_slot.remove_child(further_card);
			card_slot.add_child(further_card);
			slots_per_card.set(further_card.card_id, slot_index);
			card_slot = further_card_slot;
	card_slot_used_amount -= 1;

func draw_hand():
	reroll_left = Constants.reroll_per_turn;
	SignalBus.reroll_amount_updated.emit(reroll_left);
	
	for i in Constants.base_card_per_round:
		TileCardFactory.instance.draw_random_card();
