class_name HandPile extends CardPile

static var instance : HandPile;

var tile_cards : Array[TileCard];

func _ready() -> void:
	if instance == null:
		instance = self;
	
	SignalBus.card_drawn.connect(on_card_drawn);
	SignalBus.card_discarded.connect(on_card_discarded);
	SignalBus.card_used.connect(on_card_used);

func on_card_drawn(tile_card : TileCard):
	tile_card.modulate.a = 0; # hide the card while it was not dispatched
	tile_cards.append(tile_card);
	add_child(tile_card);
	update_card_amount();

func on_card_discarded(tile_card : TileCard):
	var tilecard_index = tile_cards.find(tile_card);
	if tilecard_index == -1: 
		return;
	cards.pop_at(tilecard_index);
	tile_cards.pop_at(tilecard_index);
	update_card_amount();

func on_card_used(tile_card : TileCard):
	cards.erase(tile_card.card_id);
	tile_cards.erase(tile_card);
	tile_card.on_discarded();

func update_tile_card_evolutions():
	for tile_card in tile_cards:
		tile_card.update_evolutions();

func update_card_amount() :
	pile_size_label.text = str(get_pile_size()) + " / " + str(Constants.base_card_hand_size);
