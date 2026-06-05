extends Control
class_name TitleScreen

@export_group("UI")
@export var new_game_button : TextureButton;
@export var continue_button : TextureButton;
@export var quit_button : TextureButton;
@export var volume_slider : HSlider;
@export_group("Scenes")
@export var next_scene_key : SceneLoader.SCENES;
var base_volume : float;

func _ready() -> void:
	init_buttons();
	init_audio_volume();

func init_buttons():
	new_game_button.button_up.connect(start_new_game);
	continue_button.button_up.connect(start_game);
	quit_button.button_up.connect(func(): get_tree().quit());
	volume_slider.drag_ended.connect(update_volume);
	if !UserData.has_save():
		continue_button.disabled = true;
		continue_button.modulate = Color.DARK_GRAY;

func start_game():
	UserData.deserialize_save();
	SceneLoader.load_scene(SceneLoader.default_game_scene);

func start_new_game():
	UserData.delete_save();
	start_game();

func init_audio_volume():
	base_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master"));
	update_volume(true);

func update_volume(value_changed: bool):
	if !value_changed: return;
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume_slider.value));
