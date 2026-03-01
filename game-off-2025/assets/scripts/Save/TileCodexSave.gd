class_name TileCodexSave extends Save

const KEY_NAME = "tile_codex"

var bookmarks : Array[String];
# TODO : save known tiles

var loaders : Dictionary[String, Callable] = {
	"bookmarks" : 
		load_bookmarks
}

func _init():
	_is_init = true;

func get_key() -> String:
	return KEY_NAME;

func to_JSON() -> Dictionary[String, Variant]:
	return {
		"bookmarks" : bookmarks
	}

func get_loader(key : String) -> Callable:
	return loaders[key];

func load_bookmarks(_bookmarks : Array):
	for bookmark in _bookmarks:
		bookmarks.push_back(str(bookmark));
