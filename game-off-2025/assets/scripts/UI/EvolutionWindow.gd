extends Control
class_name EvolutionWindow

@export_group("UI elements")
@export var card_container : Control;
@export var close_button : TextureButton;
@export var shader_holder : TextureRect;

func _ready() -> void:
	close_button.button_up.connect(close);

func setup(tile_data : CustomTileData):
	reset();
	var tile_card = TileCard.create_tile_card(tile_data.id);
	tile_card.set_meta('Draggable', false);
	tile_card.card_count.modulate = Color(0);
	tile_card.card_count_overlay.modulate = Color(0);
	shader_holder.material.set("shader_parameter/glow_color", tile_card.card_color);
	card_container.add_child(tile_card);

func reset():
	for n in card_container.get_children():
		card_container.remove_child(n);
		n.queue_free();

func close():
	visible = false;
