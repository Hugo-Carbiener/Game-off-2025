extends Control
class_name EffectTooltipContent

const effect_tooltip_scene: PackedScene = preload("res://scenes/tile_codex/EffectTooltipContent.tscn");

@export_group("Components")
@export var icon : TextureRect;
@export var title_label : Label; 
@export var description_label : Label; 

static func create_tooltip(effect : TileEffect) -> EffectTooltipContent:
	var effect_tooltip = effect_tooltip_scene.instantiate();
	effect_tooltip.setup(effect);
	return effect_tooltip;

func setup(effect : TileEffect):
	icon.texture = effect.icon;
	title_label.text = effect.title;
	description_label.text = effect.get_description();
