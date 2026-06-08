class_name TooltipFactory extends Control

## Scipt to place on elements that must display a tooltip 
##
## This overrides the default tooltip using the content set in the inspector

@export var tooltip_type : TYPE;

## Used to displayed tooltips that need additional loading
var preloaded_tooltip : Object;

enum TYPE {
	BASE,
	EFFECT
}

func _make_custom_tooltip(for_text):
	match tooltip_type:
		TYPE.BASE:
			return BaseTooltip.create_base_tooltip(for_text);
		TYPE.EFFECT:
			return preloaded_tooltip.duplicate();
