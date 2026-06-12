class_name EffectPreview extends TextureRect

static var effect_preview_scene : PackedScene = preload("res://scenes/components/EffectPreview.tscn");

@export var tooltip : TooltipFactory;
@export var bounce_factor : float;

static func create_effect_preview(effect : TileEffect) -> EffectPreview:
	var effect_preview = effect_preview_scene.instantiate();
	effect_preview.setup(effect);
	return effect_preview;

func setup(effect : TileEffect):
	if !mouse_entered.has_connections():
		mouse_entered.connect(on_mouse_enter);
	if !mouse_exited.has_connections():
		mouse_exited.connect(on_mouse_exit);
	pivot_offset = size / 2;
	texture = effect.icon;
	tooltip.preloaded_tooltip = EffectTooltip.create_effect_tooltip(effect);

func on_mouse_enter():
	var tween = get_tree().create_tween();
	tween.tween_property(self, "scale", bounce_factor * Vector2.ONE, Constants.blink_duration);

func on_mouse_exit():
	var tween = get_tree().create_tween();
	tween.tween_property(self, "scale", Vector2.ONE, Constants.blink_duration);
