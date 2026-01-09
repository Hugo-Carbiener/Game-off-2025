extends Node

var main_menu_scene_path : String = "res://scenes/TitleScreen.tscn";

func main_menu():
	get_tree().change_scene_to_file(main_menu_scene_path);

func quit_game():
	get_tree().quit();
