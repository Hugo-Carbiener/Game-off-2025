class_name CardHandInteractionArea
extends InteractionArea

## Describes an Interaction Area that holds the card hand. 
##
## A single card can be selected in this Interaction Area.

func interact():
	CardSelector.instance.on_card_selection_interaction();
