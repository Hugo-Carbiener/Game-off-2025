extends Node2D
class_name AudioManager

static var instance : AudioManager;
@export_group("Audio")
@export var victory_sound : AudioUtils.MUSICS;
@export var defeat_sound : AudioUtils.MUSICS;
@export var main_audio_sequence : AudioStream;

func _ready() -> void:
	if instance == null:
		instance = self;
	SignalBus.game_won.connect(on_game_won);
	SignalBus.game_lost.connect(on_game_lost);
	#AudioUtils.switch_music(main_audio_sequence);

func on_game_won():
	AudioUtils.toggle_music();
	AudioUtils.play_sound(AudioUtils.musics[victory_sound]);

func on_game_lost():
	AudioUtils.toggle_music();
	AudioUtils.play_sound(AudioUtils.musics[defeat_sound]);
