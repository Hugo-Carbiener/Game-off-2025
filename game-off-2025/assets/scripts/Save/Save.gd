@abstract class_name Save

var _is_init = false;

@abstract func get_key() -> String;
@abstract func to_JSON() -> Dictionary[String, Variant];
@abstract func get_loader(key : String) -> Callable;

func from_JSON(data : Dictionary):
	for field in data.keys():
		get_loader(field).call(data[field]);

func is_init() -> bool:
	return _is_init;

func vector2i_from_str(string : String) -> Vector2i:
	string.remove_chars('(');
	string.remove_chars(')');
	var sub_strings = string.split(",");
	return Vector2i(int(sub_strings[0]), int(sub_strings[1]));
