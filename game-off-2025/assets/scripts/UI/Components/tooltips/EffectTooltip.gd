class_name EffectTooltip extends Tooltip

static var effect_tooltip_scene : PackedScene = preload("res://scenes/components/tooltips/EffectTooltip.tscn");

@export var effect_tooltip_content : EffectTooltipContent;

static func create_effect_tooltip(effect : TileEffect) -> EffectTooltip:
	var tooltip = effect_tooltip_scene.instantiate();
	tooltip.setup(effect);
	return tooltip;

func setup(effect : TileEffect):
	effect_tooltip_content.setup(effect);
