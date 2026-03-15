extends Control
class_name EffectTooltip

const effect_tooltip_scene: PackedScene = preload("res://scenes/tile codex/EffectTooltip.tscn");

@export_group("Components")
@export var icon : TextureRect;
@export var description_label : Label; 

static func create_tooltip(effect : TileEffect) -> EffectTooltip:
	var effect_tooltip = effect_tooltip_scene.instantiate();
	effect_tooltip.setup(effect);
	return effect_tooltip;

func setup(effect : TileEffect):
	icon.texture = effect.icon;
	description_label.text = effect.get_description();
