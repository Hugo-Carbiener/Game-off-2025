extends Control
class_name InteractionArea

## Describes UI elements that can be interacted with via click using the ClickManager. 
## This is used for complex actions on complex objects can cannot be represented by a button.
##
## The click manager references all InteractionAreas and checks, when we click if an area can be interacted via 
## according to the current context. 

# the default actions when interacting with empty space
func interact():
	CardSelector.instance.unselect_card();
