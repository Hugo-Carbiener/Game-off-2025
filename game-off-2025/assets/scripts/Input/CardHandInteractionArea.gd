extends InteractionArea
class_name CardHandInteractionArea

# always interrupt dropping as it's the intended action
func interact() -> bool:
	## return card to hand
	CardSlotSelector.instance.on_card_slot_selection();	
	return false;
