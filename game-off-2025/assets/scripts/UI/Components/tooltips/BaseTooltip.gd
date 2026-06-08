class_name BaseTooltip extends Tooltip

static var base_tooltip_scene : PackedScene = preload("res://scenes/components/Tooltips/BaseTooltip.tscn");

@export var label : Label;

static func create_base_tooltip(content : String) -> BaseTooltip:
	var tooltip = base_tooltip_scene.instantiate();
	tooltip.setup(content);
	return tooltip;

func setup(content : String):
	label.text = content;
