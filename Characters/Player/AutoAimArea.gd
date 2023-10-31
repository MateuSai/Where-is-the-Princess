class_name AutoAimArea extends EnemyDetector

@onready var player: Player = owner

func _ready() -> void:
	super()

	Settings.auto_aim_changed.connect(_on_auto_aim_changed)
	_on_auto_aim_changed(Settings.auto_aim)


func get_direction() -> Vector2:
	return (closer_enemy.global_position - player.position).normalized() if is_instance_valid(closer_enemy) else Vector2.RIGHT


func _update_closer_enemy() -> void:
	var distance_to_closer_enemy: float = (closer_enemy.global_position - player.position).length() if is_instance_valid(closer_enemy) else INF
	for enemy in enemies_inside:
		if enemy == closer_enemy:
			continue
		var distance_to_other_enemy: float = (enemy.global_position - player.position).length()
		if distance_to_other_enemy < distance_to_closer_enemy:
			distance_to_closer_enemy = distance_to_other_enemy
			closer_enemy = enemy


func _on_auto_aim_changed(new_value: bool) -> void:
	if new_value:
		_enable()
	else:
		_disable()
