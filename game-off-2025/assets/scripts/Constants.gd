extends Node2D

## Tiles
const beacon_range = 5;
const TILE_DICT_MONSTER_KEY = "monster";
const TILE_DICT_MONSTER_PATH_KEY = "monster-path";
const TILE_REQUIREMENT_LINK = '=';
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

## Breaches
const breach_initial_maturity = 2;

## Monsters
const monster_spawn_max_tile_distance = 5;

## Beacon
const beacon_hp = 10;
