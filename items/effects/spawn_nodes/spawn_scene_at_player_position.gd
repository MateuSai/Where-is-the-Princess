class_name SpawnSceneAtPlayerPosition extends ItemEffect

var _scene: PackedScene
var _spread: float
var _interval: float
var _period: float

func _init(scene: PackedScene, spread: float=0.0, interval: float=0.001, period: float=0.002) -> void:
	_scene = scene
	_spread = spread
	_interval = interval
	_period = period

func enable(player: Player) -> void:
	var time: float = 0.0

	while time <= _interval:
		var scene_instance: Node2D = _scene.instantiate()
		scene_instance.position = player.global_position + Vector2(randf_range( - _spread, _spread), randf_range( - _spread, _spread))
		player.get_tree().current_scene.add_child(scene_instance)

		time += _period
		await player.get_tree().create_timer(_period).timeout

func disable(_player: Player) -> void:
	pass