extends Node2D

# game signals
signal game_saving

# scene signals
signal on_scene_loaded

# Codex signals
signal bookmark_clicked
signal summary_element_clicked

# World signals
signal card_drawn; # TileCard
signal card_discarded; # TileCard
signal tile_placed;
signal evolution_started;
signal evolution_finished;
signal beacon_health_updated;

# Hover signals
signal card_selected
signal card_multi_selected
signal card_unselected
signal tile_selected
signal tile_unselected

# Game signals
signal reroll_amount_updated;
signal play_phase_started;
signal play_phase_ended;
signal setup_phase_started;
signal resolution_phase_started;
signal game_won;
signal game_lost;
