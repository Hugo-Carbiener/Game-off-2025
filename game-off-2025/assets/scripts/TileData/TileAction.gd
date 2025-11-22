extends Resource
class_name TileAction

var effect : TileEffect;
var trigger : TileDataManager.TRIGGERS;

func _init(_effect : TileEffect, _trigger : TileDataManager.TRIGGERS):
	self.effect = _effect;
	self.trigger = _trigger;

func execute(monster : Monster, _trigger : TileDataManager.TRIGGERS):
	if trigger != _trigger:
		pass;
	
	effect.execute(monster);
