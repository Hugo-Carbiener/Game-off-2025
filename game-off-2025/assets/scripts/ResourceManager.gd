class_name ResourceManager extends Node2D

static var instance : ResourceManager;

var void_essences : int = 0;
var essences : Dictionary[TileDataManager.BIOMES, int] = {
	TileDataManager.BIOMES.NATURAL : 0,
	TileDataManager.BIOMES.MINERAL : 0,
	TileDataManager.BIOMES.ARTIFICIAL : 0,
}

func _ready() -> void:
	if instance == null:
		instance = self;
	void_essences = Constants.base_void_essences;

func on_setup():
	replenish_void_essences();

func replenish_void_essences():
	void_essences = Constants.base_void_essences;

func gain_resource(type : TileDataManager.BIOMES, amount : int):
	essences.set(type, essences[type] + amount);
	SignalBus.resource_gained.emit(type);

func has_resource(_essences : Dictionary[TileDataManager.BIOMES, int]) -> bool:
	for type in _essences.keys():
		if _essences[type] > essences[type]: return false;
	return true;
