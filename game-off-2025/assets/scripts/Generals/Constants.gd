extends Node2D

## Files
const save_file = "user://game_save.save";

## Tiles
const beacon_range = 5;
const TILE_DICT_MONSTER_KEY = "monster";
const TILE_DICT_MONSTER_PATH_KEY = "monster-path";
const CARDINAL_TILE_REQUIREMENT_LINK = '=';
const TILE_REQUIREMENT_AND = '&';
const TILE_REQUIREMENT_OR = '|';
const TILE_REQUIREMENT_TILES_SEPARATOR = ',';
const NEIGHBOR_TILE_COORDINATES_CODEX = {
	"N" : Vector2i.UP,
	"S" : Vector2i.DOWN,
	"E" : Vector2i.RIGHT,
	"W" : Vector2i.LEFT
}

## Tilemaps
const tilemap_offset = Vector2(0, -0.2);

## Card hand
const base_card_per_round = 5;
const base_card_hand_size = 7;
const card_draw_interval = 0.1;

## Breaches
const breaches_spawn_increase_per_round = 1;
const breach_initial_maturity = 2;
const breach_transition_duration = .75;

## Monsters
const monster_spawn_max_tile_distance = 5;
const monster_info_lifetime_duration = 1.5;
const monster_info_lifetime_movement = Vector2(0, -5.0);

## Beacon
const beacon_hp = 10;

## Tile codex
const max_bookmarks = 5;
const requirements_update_delay = 1.5;

## UI
const default_transition_duration = .75;
const blink_duration = 0.1;
const camera_transition_duration = 0.5;
