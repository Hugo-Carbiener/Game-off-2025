extends TextureButton
class_name TileCodexSummaryElement

const tile_codex_summary_element_scene: PackedScene = preload("res://scenes/Tile codex/TileCodexSummaryElement.tscn");

@export var tile_preview : TextureRect;
var tile_id : String;

static func create_tile_codex_summary_element(_tile_id : String) -> TileCodexSummaryElement:
	var summary_element = tile_codex_summary_element_scene.instantiate();
	summary_element.setup(_tile_id);
	return summary_element;

func setup(_tile_id : String):
	tile_id = _tile_id;
	var tile_data = TileDataManager.instance.tile_dictionnary[tile_id];
	if tile_data == null: return;
	
	tile_preview.texture.region = tile_data.get_texture_region();
	button_up.connect(on_click);

func on_click():
	SignalBus.summary_element_clicked.emit(tile_id);
