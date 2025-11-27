extends DropReceiver
class_name CardHandDropReceiver

func on_drop(_control_dropped : Control):
	## return card to hand
	DragAndDropHandler.instance.cancel_drag();
