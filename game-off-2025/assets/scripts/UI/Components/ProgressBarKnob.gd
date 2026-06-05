class_name ProgressBarKnob extends NinePatchRect

@export var progress_bar : TextureProgressBar;

func _ready():
	pivot_offset.x = size.x / 2;
	update_position();

func update_position():
	position.x = (progress_bar.value * progress_bar.size.x / progress_bar.max_value) - (size.x / 2);
