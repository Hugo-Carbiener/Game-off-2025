extends Node2D
class_name TileRange

static var basic_range_regex : RegEx;
static var span_range_regex : RegEx; 
static var is_init = false;

var min_range : int;
var max_range : int;

func _init(_min_range : int, _max_range : int):
	self.min_range = _min_range;
	self.max_range = _max_range;

static func init():
	if basic_range_regex == null:
		basic_range_regex = RegEx.new();
		basic_range_regex.compile("^(\\d+)$");
	if span_range_regex == null:
		span_range_regex = RegEx.new();
		span_range_regex.compile("^(\\d+)\\-(\\d+)$");
	is_init = true;

static func parse_range(range_string : String) -> TileRange:
	if !is_init: init();
	
	if range_string == null or range_string.is_empty():
		return TileRange.new(0,0);
	
	var basic_range_search = basic_range_regex.search(range_string);
	if basic_range_search != null: 
		return parse_basic_range(range_string);
		
	var span_range_search = span_range_regex.search(range_string);
	if span_range_search != null: 
		return parse_span_range(span_range_search.get_string(1), span_range_search.get_string(2));
	
	printerr("Invalid tile range : " + range_string);
	return null;

static func parse_basic_range(range_string : String) -> TileRange:
	return TileRange.new(0, int(range_string));

static func parse_span_range(_min_range : String, _max_range : String):
	return TileRange.new( int(_min_range), int(_max_range));

func range_to_string() -> String:
	if min_range <= 0:
		return str(max_range);
	return str(min_range) + "-" + str(max_range);

func get_offset_coordinates() -> Array[Vector2i]:
	var res : Array[Vector2i];
	for x in range(-max_range, max_range + 1):
		for y in range(-max_range, max_range + 1):
			var distance = abs(x) + abs(y);
			if distance >= min_range && distance <= max_range:
				res.append(Vector2i(x,y));
	return res;

func is_ranged() -> bool:
	return max_range > 0;
