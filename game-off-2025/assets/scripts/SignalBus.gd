extends Node2D

# UI signals
signal cards_amount_updated;
signal reroll_amount_updated;

# Codex signals
signal bookmark_clicked
signal summary_element_clicked

# World signals
signal card_used;
signal tile_placed;
signal evolution_started;
signal evolution_finished;
signal beacon_health_updated;

# Hover signals
signal card_selected
signal card_unselected
signal monster_hovered_in
signal monster_hovered_out
signal tile_hovered_in
signal tile_hovered_out

# Game signals
signal play_phase_started;
signal setup_phase_started;
signal resolution_phase_started;
signal game_won;
signal game_lost;
