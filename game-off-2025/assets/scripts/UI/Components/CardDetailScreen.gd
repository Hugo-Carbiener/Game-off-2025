extends Control
class_name CardDetailScreen

@export_group("Components")
@export var damage_amount_label : Label;
@export var slow_amount_label : Label;
@export var return_button_label : Label;
@export var tile_card_container : Control;
@export var effect_tooltip_container : VBoxContainer;
@export var back_button : TextureButton;

var tile_card : TileCard;
var tile_id_stack : Array[String];

func _ready() -> void:
	back_button.button_up.connect(go_back);

func setup(tile_id : String):
	reset();
	var tile_data = TileDataManager.instance.tile_dictionnary[tile_id];
	if tile_data == null: return; 
	
	damage_amount_label.text = str(tile_data.damage);
	slow_amount_label.text = str(tile_data.fatigue);
	return_button_label.text = "Close" if tile_id_stack.is_empty() else "Back";
	tile_card = TileCard.create_tile_card(tile_data.id).with_clickable_evolutions(open_evolution);
	tile_card_container.add_child(tile_card);
	for action in tile_data.actions:
		var effect_tooltip = EffectTooltip.create_tooltip(action.effect, action.trigger);
		effect_tooltip_container.add_child(effect_tooltip);

func open_evolution(tile_id : String):
	tile_id_stack.push_back(tile_card.card_id);
	setup(tile_id);

func go_back():
	if tile_id_stack.is_empty():
		GameUI.instance.toggle_card_details();
	else:
		var tile_id = tile_id_stack.pop_back();
		setup(tile_id);

func reset():
	if tile_card != null:
		tile_card.queue_free();
	for effect_tooltip in effect_tooltip_container.get_children():
		effect_tooltip.queue_free();

func _input(_event: InputEvent) -> void:
	if visible: pass
		#if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
			#GameUI.instance.toggle_card_details();
