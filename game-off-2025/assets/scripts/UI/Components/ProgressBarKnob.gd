class_name ProgressBarKnob extends NinePatchRect

@export var progress_bar : TextureProgressBar;

func _ready():
	update_position();

func update_position():
	position.x = progress_bar.value * progress_bar.size.x / progress_bar.max_value;
