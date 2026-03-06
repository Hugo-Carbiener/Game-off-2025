class_name TileCodexSave extends Save

const KEY_NAME = "tile_codex"

var bookmarks : Array[String];
var known_tiles : Array[String];
var pages_to_discover : Array[String];

var loaders : Dictionary[String, Callable] = {
	"bookmarks" : 
		load_bookmarks,
	"known_tiles" :
		load_known_tiles,
	"pages_to_discover" : 
		load_pages_to_discover
}

func _init():
	_is_init = true;

func get_key() -> String:
	return KEY_NAME;

func to_JSON() -> Dictionary[String, Variant]:
	return {
		"bookmarks" : bookmarks,
		"known_tiles" : known_tiles,
		"pages_to_discover" : pages_to_discover
	}

func get_loader(key : String) -> Callable:
	return loaders[key];

func load_bookmarks(_bookmarks : Array):
	for bookmark in _bookmarks:
		bookmarks.append(str(bookmark));

func load_known_tiles(_known_tiles : Array):
	for tile in _known_tiles:
		known_tiles.append(str(tile));

func load_pages_to_discover(_pages_to_discover : Array):
	for page in _pages_to_discover:
		pages_to_discover.append(str(page));
