extends Control
class_name CardSlot

@export var key_label : Label;

func setup(card_slot_index : int):
	key_label.text = str(card_slot_index);
