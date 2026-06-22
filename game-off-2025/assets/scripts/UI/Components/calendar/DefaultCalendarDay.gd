class_name DefaultCalendarDay extends CalendarDay

static var breach_calendar_day : PackedScene = preload("res://scenes/components/calendar/DefaultCalendarDay.tscn");

@export var label : Label;

static func create_calendar_day(_day : int) -> DefaultCalendarDay:
	var calendar_day = breach_calendar_day.instantiate();
	calendar_day.setup(_day);
	return calendar_day;

func setup(_day : int):
	day = _day;
	label.text = UIUtils.to_roman(day);
	tooltip_text = "Day " + str(day);

func on_mouse_enter():
	pass

func on_mouse_exit():
	pass
