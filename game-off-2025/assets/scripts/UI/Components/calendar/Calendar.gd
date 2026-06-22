class_name Calendar extends Control

@export_group("Days")
@export var day_anchors : Array[Control];
@export var calendar_day_container : Control;
@export_group("Phases")
@export var phases_anchors : Dictionary[GameLoop.PHASES, Control];
@export var phases_selector : TextureRect;
var calendar_days : Array[CalendarDay];
var current_phase_selector_anchor : Control;

func _ready() -> void:
	phases_selector.pivot_offset = phases_selector.size / 2;
	init_anchors();
	SignalBus.setup_phase_started.connect(on_new_phase);
	SignalBus.setup_phase_started.connect(on_new_day);
	SignalBus.harvest_phase_started.connect(on_new_phase);
	SignalBus.play_phase_started.connect(on_new_phase);
	SignalBus.resolution_phase_started.connect(on_new_phase);

func init_anchors():
	for phases_anchor in phases_anchors.values():
		phases_anchor.modulate = Color.DARK_GRAY;

func on_new_phase():
	var current_phase = GameLoop.current_phase;
	var anchor = phases_anchors[current_phase];
	var destination = anchor.position + (anchor.size / 2) - (phases_selector.size / 2) + Vector2.LEFT;
	print(str(anchor.position) + "," + str(anchor.size) + "," + str(phases_selector.size));
	if current_phase_selector_anchor != null:
		AnimationUtils.transition_color(current_phase_selector_anchor, Color.DARK_GRAY, Constants.default_transition_duration);
	AnimationUtils.transition_color(anchor, Color.WHITE, Constants.default_transition_duration);
	await AnimationUtils.move(phases_selector, phases_selector.position, destination, Constants.default_transition_duration);
	current_phase_selector_anchor = anchor;

func on_new_day():
	var day = GameLoop.current_day;
	if day == 1:
		add_new_calendar_day(1);
	add_new_calendar_day(day + 1);
	for calendar_day_idx in range(calendar_days.size()):
		var calendar_day = calendar_days[calendar_day_idx];
		var destination = day_anchors[calendar_day_idx + 1].position;
		#AnimationUtils.fade(calendar_day, 0, Constants.default_transition_duration / 2);
		AnimationUtils.move(calendar_day, calendar_day.position, destination, Constants.default_transition_duration);
		#AnimationUtils.fade(calendar_day, 1, Constants.default_transition_duration / 2, Constants.default_transition_duration / 2);
	await remove_past_calendar_day();

func add_new_calendar_day(new_day : int):
	var day_icon = get_day_icon(new_day);
	day_icon.modulate.a = 0;
	calendar_day_container.add_child(day_icon);
	day_icon.global_position = day_anchors[0].global_position;
	calendar_days.push_front(day_icon);
	AnimationUtils.fade(day_icon, 1, Constants.default_transition_duration / 2, Constants.default_transition_duration / 2);

func remove_past_calendar_day():
	if calendar_days.size() >= 4:
		var last_day = calendar_days.pop_back();
		await AnimationUtils.fade(last_day, 0, Constants.default_transition_duration / 4);
		last_day.queue_free();

func get_day_icon(day : int) -> CalendarDay:
	if GameLoop.is_breach_spawn_day(day):
		return get_breach_day_element(day);
	else:
		return get_default_day_element(day);

func get_breach_day_element(day : int) -> CalendarDay:
	return BreachCalendarDay.create_calendar_day(day);

func get_default_day_element(day : int) -> CalendarDay:
	return DefaultCalendarDay.create_calendar_day(day);
