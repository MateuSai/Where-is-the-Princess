class_name AutoAimArea extends EnemyDetector

@onready var player: Player = owner

func _ready() -> void:
	super()

	Settings.auto_aim_changed.connect(_on_auto_aim_changed)
	Settings.aim_help_changed.connect(_on_aim_help_changed)
	if Settings.auto_aim:
		_enable()
	else:
		_on_aim_help_changed(Settings.aim_help)


func get_direction() -> Vector2:
	return (closer_enemy.global_position - player.position).normalized() if is_instance_valid(closer_enemy) else Vector2.RIGHT


func get_direction_using_dir(dir: Vector2, max_angle: float) -> Vector2:
	var closer_to_dir: Character = null
	var angle: float

	for enemy: Character in enemies_inside:
		var angle_to_enemy: float = abs(dir.angle_to((enemy.global_position - player.position)))
		if (closer_to_dir == null or angle_to_enemy < angle) and angle_to_enemy < max_angle:
			closer_to_dir = enemy
			angle = angle_to_enemy

	return (closer_to_dir.global_position - player.position).normalized() if closer_to_dir else Vector2.ZERO


func _update_closer_enemy() -> void:
	var distance_to_closer_enemy: float = (closer_enemy.global_position - player.position).length() if is_instance_valid(closer_enemy) else INF
	for enemy: Character in enemies_inside:
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
		_on_aim_help_changed(Settings.aim_help)


func _on_aim_help_changed(new_value: float) -> void:
	if new_value > 0.0:
		if set_closer_enemy_timer.is_stopped():
			_enable()
	else:
		_disable()
