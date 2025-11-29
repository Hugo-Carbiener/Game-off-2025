extends Node2D

var player : AudioStreamPlayer;

enum MUSICS {
	COMBAT_1,
	COMBAT_2,
	COMBAT_3,
	START,
	MENU,
	VICTORY,
	DEFEAT
}

var musics = {
	MUSICS.COMBAT_1 : preload("res://assets/audio/Combat_1.ogg"),
	MUSICS.COMBAT_2 : preload("res://assets/audio/Combat_2.ogg"),
	MUSICS.COMBAT_3 : preload("res://assets/audio/Combat_3.ogg"),
	MUSICS.START : preload("res://assets/audio/Début_Jeu.ogg"),
	MUSICS.MENU : preload("res://assets/audio/Menus.ogg"),
	MUSICS.VICTORY : preload("res://assets/audio/Victoire.ogg"),
	MUSICS.DEFEAT : preload("res://assets/audio/Défaite.ogg")
}

@onready var tree := get_tree() # Gets the slightest of performance improvements by caching the SceneTree

func play_music(sound: AudioStream, at : float = 0, autoplay := true):
	if player == null:
		player = AudioStreamPlayer.new();
		add_child(player);
	player.stream = sound;
	player.autoplay = autoplay;
	player.play(at);
	return player;

func switch_music(sound: AudioStream):
	# prepare previous player to be killed
	var old_player = player;
	old_player.finished.connect(func(): old_player.queue_free());
	# add new player
	player = AudioStreamPlayer.new();
	add_child(player);
	cross_fade(old_player, player);
	play_music(sound, old_player.get_playback_position());

func toggle_music(paused : bool = !player.playing):
	player.playing = paused;

func _play_sound(sound: AudioStream, _player : AudioStreamPlayer, autoplay := true):
	_player.stream = sound;
	_player.autoplay = autoplay;
	_player.finished.connect(func(): _player.queue_free());
	get_tree().current_scene.add_child(_player);
	return _player;

func play_sound(sound: AudioStream, autoplay := true) -> AudioStreamPlayer:
	return _play_sound(sound, AudioStreamPlayer.new(), autoplay);

func fade_in(audio_stream_player, seconds := 1.0, tween := create_tween()):
	if not (audio_stream_player is AudioStreamPlayer or audio_stream_player is AudioStreamPlayer2D):
		push_error("Non-AudioStreamPlayer[XD] provided to Audio.fade_in(...)")
		return
	tween.tween_method(func(x): audio_stream_player.volume_db = linear_to_db(x), 0.0, db_to_linear(audio_stream_player.volume_db), seconds)
	await tween.finished;
	return;

func fade_out(audio_stream_player, seconds := 1.0, tween := create_tween()):
	if not (audio_stream_player is AudioStreamPlayer or audio_stream_player is AudioStreamPlayer2D or audio_stream_player is AudioStreamPlayer3D):
		push_error("Non-AudioStreamPlayer[XD] provided to Audio.fade_out(...)")
		return
	tween.tween_method(func(x): audio_stream_player.volume_db = linear_to_db(x), db_to_linear(audio_stream_player.volume_db), 0.0, seconds)
	tween.tween_callback(func(): audio_stream_player.stop(); audio_stream_player.queue_free())
	await tween.finished;
	return;

func cross_fade(audio_stream_player_out, audio_stream_player_in, seconds := 1.0, tween := create_tween()):
	if not (audio_stream_player_out is AudioStreamPlayer or audio_stream_player_out is AudioStreamPlayer2D or audio_stream_player_out is AudioStreamPlayer3D):
		push_error("Non-AudioStreamPlayer[XD] provided to Audio.cross_fade(...) as audio_stream_player_out")
		return
	if not (audio_stream_player_in is AudioStreamPlayer or audio_stream_player_in is AudioStreamPlayer2D or audio_stream_player_in is AudioStreamPlayer3D):
		push_error("Non-AudioStreamPlayer[XD] provided to Audio.cross_fade(...) as audio_stream_player_in")
		return
	fade_in(audio_stream_player_in, seconds, tween)
	fade_out(audio_stream_player_out, seconds, tween.parallel())
