extends DropReceiver
class_name CardHandDropReceiver

# always interrupt dropping as it's the intended action
func on_drop(_control_dropped : Control) -> bool:
	## return card to hand
	DragAndDropHandler.instance.cancel_drag();
	
	return false;
