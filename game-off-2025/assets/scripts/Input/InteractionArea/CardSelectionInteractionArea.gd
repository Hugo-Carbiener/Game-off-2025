class_name CardSelectionInteractionArea extends InteractionArea

## Describes an Interaction Area that holds a card selection. 
##
## A multiple cards can be selected in this Interaction Area to then be interacted with. 

func interact():
	CardSelector.instance.on_multi_card_selection_interaction();
