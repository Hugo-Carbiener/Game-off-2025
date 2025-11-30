extends Control
class_name MonsterInfo

@export var label : Label;
@export var tile_preview : TextureRect;
@export var icon_model : TextureRect;
var added_icons : Array[TextureRect];

func launch(tile_data : CustomTileData, text : String, icons : Array[Resource]):
	init(tile_data, text, icons);
	await start_lifetime();

func init(tile_data : CustomTileData, text : String, icons : Array[Resource]):
	visible = true;
	icon_model.visible = true;
	tile_preview.texture = tile_preview.texture.duplicate();
	tile_preview.texture.region = Rect2(tile_data.atlas_texture_coordinates.x, tile_data.atlas_texture_coordinates.y , TileDataManager.instance.tile_size.x, TileDataManager.instance.tile_size.y);
	modulate = tile_data.color;
	label.label_settings = label.label_settings.duplicate();
	label.label_settings.font_color = tile_data.color;
	label.text = text;
	
	for child in get_children():
		if child is TextureRect and added_icons.has(child):
			child.queue_free();
	
	for icon in icons:
		var icon_container = icon_model.duplicate();
		added_icons.append(icon_container);
		icon_container.texture = icon_container.texture.duplicate();
		icon_container.texture = icon;
		add_child(icon_container);
	icon_model.visible = false;

func start_lifetime():
	var tween = get_tree().create_tween();
	tween.set_parallel(true);
	tween.tween_property(self, "modulate", Color(0, 0, 0, 0), Constants.monster_info_lifetime_duration).set_ease(Tween.EASE_IN);
	tween.set_parallel(false);
	tween.tween_callback(func(): visible = false);
	await tween.finished;
