extends Node2D

# UI signals
signal cards_amount_updated;
signal reroll_amount_updated;

# World signals
signal card_used;
signal tile_placed;
signal evolution_started;
signal evolution_finished;
signal beacon_health_updated;

# Game signals
signal round_started;
signal game_won;
signal game_lost;
