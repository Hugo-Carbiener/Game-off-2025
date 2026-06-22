class_name BreachCalendarDay extends CalendarDay

static var breach_calendar_day : PackedScene = preload("res://scenes/components/calendar/CalendarBreachDay.tscn");

static func create_calendar_day(_day : int) -> BreachCalendarDay:
	var calendar_day = breach_calendar_day.instantiate();
	calendar_day.setup(_day);
	return calendar_day;

func setup(_day : int):
	day = _day;
	tooltip_text = "Day " + str(day) +": A breach will appear and destroy nearby tiles."

func on_mouse_enter():
	if day > GameLoop.current_day:
		IndicationTilemap.instance.display_next_breach();

func on_mouse_exit():
	if day > GameLoop.current_day:
		IndicationTilemap.instance.clear_next_breach();
