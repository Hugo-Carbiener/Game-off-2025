extends Node

var card_deck : Dictionary[String, int];
var tile_codex_save : TileCodexSave = TileCodexSave.new();
var fight_save : FightSave = FightSave.new();
var modules : Dictionary[String, Save] = {
	tile_codex_save.get_key() : tile_codex_save,
	fight_save.get_key() : fight_save
};

func _ready() -> void:
	for card in TileDataManager.playable_tiles:
		card_deck.set(card, 1);
	SignalBus.play_phase_started.connect(auto_save);

func auto_save():
	SignalBus.game_saving.emit();
	serialize_save();

func serialize_save():
	var save_file = FileAccess.open(Constants.save_file, FileAccess.WRITE)
	save_file.store_line("{");
	for module in modules.values():
		var save_data = JSON.stringify(module.to_JSON());
		var EOL = "," if module != modules.values().get(modules.size() - 1) else "";
		save_file.store_line('"' + module.get_key() + '":' + save_data + EOL);
	save_file.store_line("}");


func deserialize_save():
	if !has_save(): return;

	var save_file = FileAccess.open(Constants.save_file, FileAccess.READ);
	var json_string = save_file.get_as_text();
	var json = JSON.new();
	var parse_result = json.parse(json_string);
	if parse_result != OK:
		printerr("Error while parsing save: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line());
		return;
	if json.data == null or json.data.is_empty(): return;
	
	for data_key in json.data.keys():
		if !modules.has(data_key):
			printerr("Invalid module key in user data : " + data_key);
			continue;
		
		var module = modules[data_key];
		module.from_JSON(json.data[data_key]);
		module._is_init = true;

func delete_save():
	if !has_save(): return;
	
	DirAccess.remove_absolute(Constants.save_file);

func has_save() -> bool:
	return FileAccess.file_exists(Constants.save_file);

func get_known_tiles() -> Array[String]:
	return tile_codex_save.known_tiles;
