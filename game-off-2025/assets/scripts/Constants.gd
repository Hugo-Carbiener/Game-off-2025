extends Node2D

## Tiles
const beacon_range = 5;
const TILE_DICT_MONSTER_KEY = "monster";
const TILE_DICT_MONSTER_PATH_KEY = "monster-path";
const TILE_REQUIREMENT_LINK = '=';
const TILE_REQUIREMENT_AND = '&';
const TILE_REQUIREMENT_OR = '|';
const TILE_REQUIREMENT_TILES_SEPARATOR = ',';
const TILE_ACTIONS_SEPARATOR = ',';
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
const card_slot_amount = 5;
var damage_icons : Dictionary[String, Resource] = {
	"low" = load("res://assets/sprites/UI_card_icon_low_damage.png"),
	"medium" = load("res://assets/sprites/UI_card_icon_medium_damage.png"),
	"high" = load("res://assets/sprites/UI_card_icon_high_damage.png")
}
var fatigue_icons : Dictionary[String, Resource] = {
	"low" = load("res://assets/sprites/UI_card_icon_low_fatigue.png"),
	"medium" = load("res://assets/sprites/UI_card_icon_medium_fatigue.png"),
	"high" = load("res://assets/sprites/UI_card_icon_high_fatigue.png")
}

## Breaches
const breaches_spawn_increase_per_round = 1;
const breach_initial_maturity = 2;
const breach_transition_duration = .75;

## Monsters
const monster_spawn_max_tile_distance = 5;
const monster_info_lifetime_duration = 2;
const monster_info_lifetime_movement = Vector2(0, -20.0);
var monster_info_icons : Dictionary[String, Resource] = {
	"damage" = load("res://assets/sprites/UI_card_icon_low_damage.png")
	}

## Beacon
const beacon_hp = 10;
