extends DropReceiver
class_name RerollDropReceiver

@onready var reroll_animation = $RerollAnimation;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	SignalBus.reroll_amount_updated.connect(_on_reroll_amount_updated);

# always returns false, we always interrupt the dropping after the first card
func on_drop(control_dropped : Control) -> bool:
	## place corresponding tile in the tilemap
	if control_dropped is not TileCard : return false;
	
	DragAndDropHandler.instance.cancel_drag();
	control_dropped.on_card_reroll();
	
	return false;
	
func _on_reroll_amount_updated(reroll_amount: int):
	if reroll_amount == 0:
		reroll_animation.self_modulate.a = 0.5;
		reroll_animation.stop();
	else: 
		reroll_animation.self_modulate.a = 1;
		reroll_animation.play("default");
