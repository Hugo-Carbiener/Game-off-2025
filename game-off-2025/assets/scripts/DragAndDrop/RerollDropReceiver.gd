extends DropReceiver
class_name RerollDropReceiver

func on_drop(control_dropped : Control):
	## place corresponding tile in the tilemap
	if control_dropped is not TileCard : return;
	
	DragAndDropHandler.destroy_movable_copy();
	control_dropped.on_card_reroll();
	
	
