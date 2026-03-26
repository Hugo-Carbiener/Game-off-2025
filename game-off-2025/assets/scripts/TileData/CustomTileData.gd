class_name CustomTileData

var id : String;
var color : Color;
var name : String;
var damage : int;
var effect_range : TileRange;
var description : String;
var atlas_coordinates : Vector2;
var atlas_texture_coordinates : Vector2;
var is_playable : bool;
var is_util : bool;
var evolutions : Array[String];
var devolutions : Array[String];
var requirement : TileRequirement;
var effects : Array[TileEffect];

func _init(
		_id: String,
		_color: Color,
		_name : String,
		_damage : int,
		_range : String,
		_description : String,
		_atlas_coordinates : Vector2,
		_atlas_texture_coordinates : Vector2,
		_is_playable : bool,
		_is_util : bool,
		_evolutions : Array,
		_requirements : String,
		_effects : Array):
	self.id = _id;
	self.color = _color;
	self.name = _name;
	self.damage = _damage;
	self.effect_range = TileRange.parse_range(_range);
	self.description = _description;
	self.atlas_coordinates = _atlas_coordinates;
	self.atlas_texture_coordinates = _atlas_texture_coordinates;
	self.is_playable = _is_playable;
	self.is_util = _is_util;
	self.evolutions = [];
	evolutions.assign(_evolutions);
	self.requirement = parse_requirements(_requirements);
	self.effects = parse_effects(_effects);

func parse_requirements(_requirement : String) -> TileRequirement:
	if _requirement == null or _requirement.is_empty(): return null;
	
	if _requirement.begins_with('('):
		var parenthesis_count = 0;
		for i in range(_requirement.length()):
			if _requirement[i] == '(' :
				parenthesis_count += 1;
			if _requirement[i] == ')' :
				parenthesis_count -= 1;
			if parenthesis_count < 0:
				print("Parenthesis error when parsing requirements " + _requirement + " of tile " + name);
				return null;
			
			if parenthesis_count == 0 and i < _requirement.length() - 1:
				break;
			elif parenthesis_count == 0 and i == _requirement.length() - 1:
				_requirement = _requirement.substr(1, _requirement.length()-2);
	
	var is_sub_group = false;
	for i in range(_requirement.length()):
		if _requirement[i] == '(':
			is_sub_group = true;
			continue;
		elif _requirement[i] == ')' and is_sub_group:
			is_sub_group = false;
			continue;
		elif is_sub_group:
			continue;
		elif _requirement[i] == Constants.TILE_REQUIREMENT_AND and !is_sub_group:
			var split_strings = _requirement.split(Constants.TILE_REQUIREMENT_AND);
			var requirement_and = TileRequirementsAnd.new();
			for split_string in split_strings:
				requirement_and.requirements.append(parse_requirements(split_string))
			return requirement_and;
		elif _requirement[i] == Constants.TILE_REQUIREMENT_OR and !is_sub_group:
			var split_strings = _requirement.split(Constants.TILE_REQUIREMENT_OR);
			var requirement_or = TileRequirementsOr.new();
			for split_string in split_strings:
				requirement_or.requirements.append(parse_requirements(split_string))
			return requirement_or;
		elif !is_sub_group and i == _requirement.length() - 1 :
			
			return null;
	print("Invalid tile requirement " + _requirement + " for tile " + name);
	return null;

func parse_requirement(requirement_string : String) -> TileRequirement:
	var cardinal_requirement_search = TileDataManager.cardinal_tile_requirement_regex.search(requirement_string);
	if cardinal_requirement_search != null: 
		return CardinalTileRequirement.parse(cardinal_requirement_search.get_string(1), cardinal_requirement_search.get_string(2));

	var tile_amount_requirement_search = TileDataManager.tile_amount_requirement_regex.search(requirement_string);
	if tile_amount_requirement_search != null: 
		return TileAmountRequirement.parse(tile_amount_requirement_search.get_string(1), tile_amount_requirement_search.get_string(2), tile_amount_requirement_search.get_string(3));
	
	printerr("Could not parse tile requirement " + requirement_string + " for tile " + id + ".");
	return null;

func parse_effects(_effects : Array) -> Array[TileEffect]:
	var tile_effects : Array[TileEffect];
	for resource_path in _effects:
		var effect := load(resource_path) as TileEffect;
		if effect == null:
			printerr("Effect at path " + resource_path + " could not be loaded for tile " + self.id);
			continue;
		
		tile_effects.append(effect);
	return tile_effects;

func get_texture_region() -> Rect2:
	return Rect2(atlas_texture_coordinates.x, atlas_texture_coordinates.y , TileDataManager.tile_size.x, TileDataManager.tile_size.y);

func get_cells_in_range() -> Array[Vector2i]:
	return effect_range.get_offset_coordinates();

func execute_effects(trigger : TileDataManager.TRIGGERS, tile_position : Vector2i):
	for effect in effects:
		await effect.execute(trigger, tile_position, self);
