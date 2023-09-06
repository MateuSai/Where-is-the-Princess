class_name AutoAimArea extends Area2D

var closer_enemy: Enemy = null

var enemies_inside: Array[Enemy] = []

@onready var player: Player = owner
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var set_closer_enemy_timer: Timer = $SetCloserEnemyTimer

func _ready() -> void:
	body_entered.connect(_on_enemy_entered)
	body_exited.connect(_on_enemy_exited)
	set_closer_enemy_timer.timeout.connect(_update_closer_enemy)

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


func _enable() -> void:
	set_closer_enemy_timer.start()
	collision_shape.set_deferred("disabled", false)


func _disable() -> void:
	set_closer_enemy_timer.stop()
	collision_shape.set_deferred("disabled", true)


func _on_enemy_entered(enemy: Enemy) -> void:
	enemies_inside.push_back(enemy)


func _on_enemy_exited(enemy: Enemy) -> void:
	enemies_inside.erase(enemy)
	if enemy == closer_enemy:
		_update_closer_enemy()
