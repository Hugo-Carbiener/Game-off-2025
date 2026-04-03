extends InteractionArea
class_name RerollInteractionArea

@export var reroll_animation : TextureRect;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.reroll_amount_updated.connect(_on_reroll_amount_updated);

func interact():
	var selected_card = CardSelector.instance.get_selected_card();
	if selected_card == null: return false;
	
	CardSelector.instance.unselect_card();
	selected_card.on_card_reroll();

func _on_reroll_amount_updated(reroll_amount: int):
	if reroll_amount == 0:
		reroll_animation.self_modulate.a = 0.5;
	else: 
		reroll_animation.self_modulate.a = 1;
