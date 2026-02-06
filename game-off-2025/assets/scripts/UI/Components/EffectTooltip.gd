extends Control
class_name EffectTooltip

const effect_tooltip_scene: PackedScene = preload("res://scenes/Tile codex/TileCodexBookmark.tscn");

@export_group("Components")
@export var icon : TextureRect;
@export var description_label : Label; 

static func create_tooltip(effect : TileEffect) -> EffectTooltip:
	var effect_tooltip = effect_tooltip_scene.instantiate();
	effect_tooltip.init(effect);
	return effect_tooltip;

func init(effect : TileEffect):
	if effect.get_icons().size() > 0:
		icon.texture = effect.get_icons()[0];
	description_label.text = effect.description;
