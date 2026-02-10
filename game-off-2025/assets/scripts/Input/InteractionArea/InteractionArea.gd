extends Control
class_name InteractionArea

# the default actions when interacting with empty space
func interact():
	CardSlotSelector.instance.unselect_card_slot();
