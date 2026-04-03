class_name DiscardPile extends Control

@export var tile_preview : Sprite2D;

func _ready() -> void:
	SignalBus.card_used.connect(on_card_used);

func on_card_used(_tile_card : TileCard):
	var tween = get_tree().create_tween();
	tween.tween_callback(on_transition_start.bind(_tile_card));
	tween.set_parallel(true);
	tween.tween_property(tile_preview, "position", position, Constants.default_transition_duration).set_ease(Tween.EASE_OUT);
	tween.tween_callback(on_transition_end);

func on_transition_start(tile_card : TileCard):
	var tile_data = TileDataManager.tile_dictionnary[tile_card.card_id];
	if tile_data == null: return;
	
	tile_preview.texture.region = tile_data.get_texture_region();
	tile_preview.position = get_local_mouse_position();
	tile_preview.visible = true;

func on_transition_end():
	tile_preview.visible = false;
