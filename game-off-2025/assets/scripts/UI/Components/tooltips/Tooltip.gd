class_name Tooltip extends Control

@export var fade_in_duration : float = 0.2;

func _ready() -> void:
	self.modulate = Color.TRANSPARENT;
	AnimationUtils.fade(self, 1, fade_in_duration);
