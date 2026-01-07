extends Control
class_name EffectTooltip

const effect_tooltip_scene: PackedScene = preload("res://scenes/components/EffectTooltip.tscn");

@export_group("Components")
@export var icon : TextureRect;
@export var title_label : Label;
@export var trigger_label : Label;
@export var description_label : Label; 

static func create_tooltip(effect : TileEffect, trigger : TileDataManager.TRIGGERS) -> EffectTooltip:
	var effect_tooltip = effect_tooltip_scene.instantiate();
	effect_tooltip.init(effect, trigger);
	return effect_tooltip;

func init(effect : TileEffect, trigger : TileDataManager.TRIGGERS):
	if effect.get_icons().size() > 0:
		icon.texture = effect.get_icons()[0];
	title_label.text = effect.title;
	description_label.text = effect.description;
	trigger_label.text = str(trigger);
