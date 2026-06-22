@abstract class_name CalendarDay extends TooltipFactory

var day : int;

func _ready() -> void:
	mouse_entered.connect(on_mouse_enter);
	mouse_exited.connect(on_mouse_exit);

@abstract func on_mouse_enter();
@abstract func on_mouse_exit();
