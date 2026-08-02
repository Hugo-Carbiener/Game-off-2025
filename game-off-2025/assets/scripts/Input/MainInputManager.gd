extends Node2D
class_name MainInputManager

@export_group("Hold input variables")
@export var progress_bar : TextureProgressBar;
@export var hold_input_minimum_duration : float;
@export var hold_input_required_duration : float;
var hold_input : bool = false;
var hold_input_time : float = 0;

# There are two playing mode: 2 clicks and number key + click
# Save the initial click position if not already in click mode
func _input(event: InputEvent) -> void:
	if event.is_action_released('pause-game'):
		GameUI.instance.toggle_pause_window();
	
	if UserSettings.are_input_blocked : return;

	if event.is_action_released('left-click'):
		ClickManager.on_left_click();

	if event.is_action_released('right-click'):
		CardSelector.instance.unselect_card();
	
	if event.is_action_released('debug-generate-card'):
		DrawPile.instance.draw_random_card();
	
	if event.is_action_released("debug-destroy-tile"):
		MainTilemap.instance.destroy_tile(MainTilemap.instance.local_to_map(MainTilemap.instance.get_local_mouse_position()));
	
	if event.is_action_released("debug-instability-increase"):
		for breach in MonsterFactory.breaches.values():
			breach.gain_instability(5, Vector2i.ZERO);
			breach.check_state();
	
	if event.is_action_released("debug-instability-decrease"):
		for breach in MonsterFactory.breaches.values():
			breach.gain_instability(-5, Vector2i.ZERO);
			breach.check_state();
	
	if event.is_action_released("debug-spawn-monster"):
		var pos = Vector2i(randi() % (Constants.beacon_range * 2) - Constants.beacon_range, randi() % (Constants.beacon_range * 2) - Constants.beacon_range);
		if !MonsterFactory.breaches.has(pos) and !MonsterFactory.monsters.has(pos) and !MainTilemap.instance.tiles.has(pos):
			MonsterFactory.instance.spawn_breach(pos, Constants.breach_setup_delay);
	
	if event.is_action_released('debug-discard-left-most'):
		var tile_card = HandPile.instance.tile_cards[0];
		if tile_card != null:
			DiscardPile.instance.discard_from_card(tile_card);

	if event.is_action_released("debug-natural-resource-increase"):
		ResourceManager.instance.gain_resource(TileDataManager.BIOMES.NATURAL, 1, Vector2i.ZERO);

	if event.is_action_released("debug-mineral-resource-increase"):
		ResourceManager.instance.gain_resource(TileDataManager.BIOMES.MINERAL, 1, Vector2i.ZERO);
		
	if event.is_action_released("debug-artificial-resource-increase"):
		ResourceManager.instance.gain_resource(TileDataManager.BIOMES.ARTIFICIAL, 1, Vector2i.ZERO);

	if event.is_action_pressed('debug-next-phase'):
		GameLoop.start_phase(GameLoop.get_next_phase());
