extends InteractionArea
class_name CardHandInteractionArea

func interact():
	CardSelector.instance.on_card_selection();
