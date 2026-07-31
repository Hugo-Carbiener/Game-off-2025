class_name FightSave extends Save

const KEY_NAME = "fight"

var day : int; 
var phase : GameLoop.PHASES;
var tiles : Dictionary[Vector2i, String];
var hand_cards : Array[String];
var draw_cards : Array[String];
var discard_cards : Array[String];
var monsters : Array[Vector2i];
var breaches : Dictionary[Vector2i, int];
var beacon_health : int;

var loaders : Dictionary[String, Callable] = {
	"day" : 
		load_day,
	"phase" : 
		load_phase,
	"tiles" : 
		load_tiles,
	"hand" : 
		load_hand,
	"draw" : 
		load_draw,
	"discard" : 
		load_discard,
	"monsters" : 
		load_monsters,
	"breaches" : 
		load_breaches,
	"beacon_health" : 
		load_beacon_health
}

func update(_day: int, _phase: GameLoop.PHASES, _tiles : Dictionary[Vector2i, String], _hand : Array[String], _draw : Array[String], _discard : Array[String], _monsters : Array[Vector2i], _breaches : Dictionary[Vector2i, int], _beacon_health : int):
	self.day = _day;
	self.phase = _phase;
	self.tiles = _tiles;
	self.hand_cards = _hand;
	self.draw_cards = _draw;
	self.discard_cards = _discard;
	self.monsters = _monsters;
	self.breaches = _breaches;
	self.beacon_health = _beacon_health;
	self._is_init = true;

func get_key() -> String:
	return KEY_NAME;

func to_JSON() -> Dictionary[String, Variant]:
	return {
		"day" : day,
		"phase" : phase,
		"tiles" : tiles,
		"hand" : hand_cards,
		"draw" : draw_cards,
		"discard" : discard_cards,
		"monsters" : monsters,
		"breaches" : breaches,
		"beacon_health" : beacon_health
	}

## loaders

func get_loader(key : String) -> Callable:
	return loaders[key];

func load_day(_day : int):
	day = _day;

func load_phase(_phase : int):
	phase = int(_phase) as GameLoop.PHASES;

func load_tiles(_tiles : Dictionary):
	for key in _tiles.keys():
		tiles.set(vector2i_from_str(key), str(_tiles[key]));

func load_hand(_cards : Array):
	for tile_id in _cards:
		hand_cards.append(str(tile_id));

func load_draw(_cards : Array):
	for tile_id in _cards:
		draw_cards.append(str(tile_id));

func load_discard(_cards : Array):
	for tile_id in _cards:
		discard_cards.append(str(tile_id));

func load_monsters(_monsters : Array):
	for position in _monsters:
		monsters.append(vector2i_from_str(position));

func load_breaches(_breaches : Dictionary):
	for key in _breaches.keys():
		breaches.set(vector2i_from_str(key), int(_breaches[key]));

func load_beacon_health(_health : int):
	beacon_health = _health;
