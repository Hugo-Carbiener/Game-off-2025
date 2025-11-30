extends CanvasLayer
class_name TitleScreen

@export_group("Audio")
@export var music : AudioUtils.MUSICS;
@export var game_start_music : AudioUtils.MUSICS;
var base_volume : float;
@export_group("UI")
@export var start_button : TextureButton;
@export var quit_button : TextureButton;
@export var volume_slider : HSlider;
@export_group("Scenes")
@export var next_scene_path : String = "res://scenes/Tutorial_1.tscn";

func _ready() -> void:
	init_audio();
	start_button.button_up.connect(start_game);
	quit_button.button_up.connect(func(): get_tree().quit());
	volume_slider.drag_ended.connect(update_volume);

func start_game():
	AudioUtils.fade_in(AudioUtils.play_music(AudioUtils.musics[game_start_music]), 2);
	get_tree().change_scene_to_file(next_scene_path);

func init_audio():
	base_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"));
	AudioUtils.fade_in(AudioUtils.play_music(AudioUtils.musics[music]), 2);

func update_volume(value_changed: bool):
	if !value_changed: return;
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume_slider.value))
