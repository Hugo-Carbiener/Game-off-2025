class_name ResourceManager extends Node2D

static var instance : ResourceManager;

var essences : Dictionary[TileDataManager.BIOMES, int] = {
	TileDataManager.BIOMES.NATURAL : 0,
	TileDataManager.BIOMES.MINERAL : 0,
	TileDataManager.BIOMES.ARTIFICIAL : 0,
}

func _ready() -> void:
	if instance == null:
		instance = self;

func gain_resource(type : TileDataManager.BIOMES, amount : int):
	essences.set(type, essences[type] + amount);
	SignalBus.resource_gained.emit();

func use_resource(type : TileDataManager.BIOMES, amount : int):
	essences.set(type, essences[type] - amount);
	SignalBus.resource_used.emit();

func has_resources(_essences : Dictionary[TileDataManager.BIOMES, int]) -> bool:
	for type in _essences.keys():
		if _essences[type] > essences[type]: return false;
	return true;

func can_pay_for(tile_data : CustomTileData) -> bool:
	return has_resources(tile_data.cost.to_dictionary());
