class_name DrawPile extends TextureButton

var cards : Dictionary[String, int] = {
	"grove" : 2,
	"mountain" : 1,
	"road" : 1,
	"brambles" : 1,
	"chasm" : 1,
	"great-tree" : 1,
	"lava" : 1,
}
var detail_is_active : bool = false;

@export var folding_icon : TextureRect;
@export var deck_window : Control;
@export var deck_element_container_window : Control;

func _ready() -> void:
	pivot_offset = size / 2;
	SignalBus.card_drawn.connect(draw);
	button_down.connect(on_click);

func draw(tile_card : TileCard):
	AnimationUtils.bounce(self, 1.5);
	tile_card.visible = false;
	TileCardFactory.instance.add_child(tile_card);
	await CardMovementAnimation.launch_card_movement_animation(tile_card, global_position + size / 2, tile_card.global_position, self);
	tile_card.visible = true;
	TileCardFactory.instance.update_card_count_label();

func on_click():
	detail_is_active = !detail_is_active;
	if detail_is_active:
		await open_deck();
	else:
		await close_deck();
	folding_icon.flip_v = detail_is_active;

func open_deck():
	var card_amount = get_deck_size();
	var deck_elements : Array[DeckElement];
	for tile_id in cards.keys():
		deck_elements.append(DeckElement.create_deck_element(tile_id, (float(cards[tile_id]) / card_amount) * 100));
	deck_window.modulate.a = 0;
	deck_window.visible = true;
	await AnimationUtils.fade(deck_window, Color.WHITE, 0.1);
	for deck_element in deck_elements:
		if deck_element == null: continue;
		await AnimationUtils.add_child_fade_in(deck_element_container_window, deck_element, 0.1);

func close_deck():
	var container_children = deck_element_container_window.get_children();
	for deck_element_idx in range(container_children.size() - 1, -1, -1):
		var deck_element = container_children[deck_element_idx];
		if deck_element is not DeckElement: continue;
		
		await AnimationUtils.delete_child_fade_out(deck_element, 0.1);
	await AnimationUtils.fade(deck_window, Color.TRANSPARENT, 0.1);
	deck_window.visible = false;

func get_deck_size() -> int:
	var sum = 0;
	for card_amount in cards.values():
		sum += card_amount;
	return sum;
