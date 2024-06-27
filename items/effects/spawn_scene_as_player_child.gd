class_name SpawnSceneAsPlayerChild extends ItemEffect

var _scene: PackedScene
var _instance: Node

func _init(scene: PackedScene, ) -> void:
	_scene = scene

func enable(player: Player) -> void:
	_instance = _scene.instantiate()
	player.add_child(_instance)

func disable(_player: Player) -> void:
	if is_instance_valid(_instance):
		_instance.queue_free()

func get_description() -> String:
	return ""