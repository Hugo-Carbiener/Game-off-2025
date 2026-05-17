class_name PhaseTitle extends Control

@export_group("Components")
@export var phase_title : Label
@export var phase_sub_title : Label
@export_group("Durations")
@export var lifetime_duration : float;

var titles_per_phase = {
	GameLoop.PHASES.SETUP : "Day %s",
	GameLoop.PHASES.PLAY : "Your Turn",
	GameLoop.PHASES.RESOLUTION : "Monsters Turn",
}

var sub_titles_per_phase = {
	GameLoop.PHASES.SETUP : "Breaches appear and evolve",
	GameLoop.PHASES.PLAY : "Reforge the land, prepare for an offensive",
	GameLoop.PHASES.RESOLUTION : "Monsters are coming out of the breaches",
}

func init(title : String, sub_title : String) :
	phase_title.text = title.capitalize() % (GameLoop.current_day + 1) if title.contains("%") else title.capitalize();
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
	
