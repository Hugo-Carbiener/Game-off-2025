extends Node2D

var main_menu_scene_path : String = "res://scenes/TitleScreen.tscn";

func main_menu():
	get_tree().change_scene_to_file(main_menu_scene_path);

func quit_game():
	get_tree().quit();

func to_roman(number : int) -> String:
	var result = "";
	var values = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
	var romans = ["M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"];
	for i in range(values.size()) :
		while (number >= values[i]):
			number -= values[i];
			result += romans[i];
	return result;
