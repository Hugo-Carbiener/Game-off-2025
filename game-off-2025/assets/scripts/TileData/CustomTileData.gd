class_name CustomTileData

var name : String;
var damage : int;
var description : String;
var atlas_coordinates : Vector2;
var atlas_texture_coordinates : Vector2;
var is_playable : bool;
var evolutions : Array[String];
var requirement : TileRequirement;

func _init(_name : String, 
		_damage : int, 
		_description : String, 
		_atlas_coordinates : Vector2, 
		_atlas_texture_coordinates : Vector2, 
		_is_playable : bool,
		_evolutions : Array,
		_requirement : String):
	self.name = _name;
	self.damage = _damage;
	self.description = _description;
	self.atlas_coordinates = _atlas_coordinates;
	self.atlas_texture_coordinates = _atlas_texture_coordinates;
	self.is_playable = _is_playable;
	self.evolutions = [];
	evolutions.assign(_evolutions);
	self.requirement = parse_requirements(_requirement);

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
		elif !is_sub_group:
			var split_strings = _requirement.split(Constants.TILE_REQUIREMENT_LINK);
			var requirement_string = TileRequirement.new();
			requirement_string.relative_tilemap_coordinate = Constants.NEIGHBOR_TILE_COORDINATES_CODEX[split_strings[0]];
			requirement_string.possible_tiles = split_strings[1].split(Constants.TILE_REQUIREMENT_TILES_SEPARATOR);
			return requirement_string;
		else :
			print("Unknown situation at index " + str(i) + " while parsing tile requirement " + _requirement);
			return null;
	print("Invalid tile requirement " + _requirement + " for tile " + name);
	return null;
