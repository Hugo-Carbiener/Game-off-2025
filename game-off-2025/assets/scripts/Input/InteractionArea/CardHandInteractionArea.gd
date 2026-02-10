extends InteractionArea
class_name CardHandInteractionArea

func interact():
	CardSlotSelector.instance.on_card_slot_selection();
