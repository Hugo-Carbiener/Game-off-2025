extends DropReceiver
class_name RerollDropReceiver

@onready var reroll_animation = $RerollAnimation;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	SignalBus.reroll_amount_updated.connect(_on_reroll_amount_updated);

func on_drop(control_dropped : Control):
	## place corresponding tile in the tilemap
	if control_dropped is not TileCard : return;
	
	DragAndDropHandler.instance.destroy_movable_copy();
	control_dropped.on_card_reroll();
	
	
func _on_reroll_amount_updated(reroll_amount: int):
	if reroll_amount == 0:
		reroll_animation.self_modulate.a = 0.5;
		reroll_animation.stop();
	else: 
		reroll_animation.self_modulate.a = 1;
		reroll_animation.play("default");
