class_name PhaseTitle extends Control

@export_group("Components")
@export var phase_title : Label
@export var phase_sub_title : Label
@export_group("Durations")
@export var lifetime_duration : float;

var titles_per_phase = {
	GameLoop.PHASES.SETUP : "day %s",
	GameLoop.PHASES.PLAY : "your turn",
	GameLoop.PHASES.RESOLUTION : "monsters turn",
}

var sub_titles_per_phase = {
	GameLoop.PHASES.SETUP : "New threats appears, prepare accordingly",
	GameLoop.PHASES.PLAY : "Close breaches, fend off the monsters",
	GameLoop.PHASES.RESOLUTION : "Hold fast, monsters are comming",
}

func init(title : String, sub_title : String) :
	phase_title.text = title.capitalize() % (GameLoop.day_number + 1) if title.contains("%") else title.capitalize();
	phase_sub_title.text = sub_title;
	modulate.a = 0;
	visible = true;

func launch(phase : GameLoop.PHASES):
	init(titles_per_phase[phase], sub_titles_per_phase[phase]);
	var tween = get_tree().create_tween();
	tween.tween_property(self, "modulate:a", 1., Constants.default_transition_duration).set_ease(Tween.EASE_OUT);
	tween.tween_interval(lifetime_duration);
	tween.tween_property(self, "modulate:a", 0., Constants.default_transition_duration).set_ease(Tween.EASE_IN);
	await tween.finished;
	visible = false;
	
