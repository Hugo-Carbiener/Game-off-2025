extends Control
class_name InteractionArea

# the default actions when interacting with empty space
func interact():
	CardSelector.instance.unselect_card();
