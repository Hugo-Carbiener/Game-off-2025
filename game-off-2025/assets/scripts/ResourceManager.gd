class_name ResourceManager extends Node2D

static var instance : ResourceManager;

@export var essence_storage : Dictionary[TileDataManager.BIOMES, Control];

var essences : Dictionary[TileDataManager.BIOMES, int] = {
	TileDataManager.BIOMES.NATURAL : 0,
	TileDataManager.BIOMES.MINERAL : 0,
	TileDataManager.BIOMES.ARTIFICIAL : 0,
}

func _ready() -> void:
	if instance == null:
		instance = self;

func gain_resource(type : TileDataManager.BIOMES, amount : int, from : Vector2i):
	essences.set(type, essences[type] + amount);
	var destination = essence_storage[type];
	await ElementMovementAnimation.launch_element_movement_animation_with_texture(TileDataManager.essence_icons[type], MainTilemap.instance.map_to_local(from), destination.global_position + (destination.size / 2), self);
	SignalBus.resource_gained.emit(type);

func use_resource(type : TileDataManager.BIOMES, amount : int):
	var essence_amount = max(0, essences[type] - amount);
	essences.set(type, essence_amount);
	SignalBus.resource_used.emit(type);

func has_resources(_essences : Dictionary[TileDataManager.BIOMES, int]) -> bool:
	for type in _essences.keys():
		if _essences[type] > essences[type]: return false;
	return true;

func can_pay_for(tile_data : CustomTileData) -> bool:
	return has_resources(tile_data.cost.to_dictionary());

func pay_for(tile_data : CustomTileData):
	var cost = tile_data.cost.to_dictionary();
	for type in cost.keys():
		use_resource(type, cost[type]);
