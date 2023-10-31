class_name EnemyDetector extends Area2D


var closer_enemy: Character = null

var enemies_inside: Array[Character] = []

@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var set_closer_enemy_timer: Timer = $SetCloserEnemyTimer


func _ready() -> void:
	assert(collision_shape)

	body_entered.connect(_on_enemy_entered)
	body_exited.connect(_on_enemy_exited)
	set_closer_enemy_timer.timeout.connect(_update_closer_enemy)


func get_direction() -> Vector2:
	push_error("You should override this function")
	return Vector2.ZERO


func _update_closer_enemy() -> void:
	push_error("You should override this function")


func _enable() -> void:
	set_closer_enemy_timer.start()
	_update_closer_enemy()
	collision_shape.set_deferred("disabled", false)


func _disable() -> void:
	set_closer_enemy_timer.stop()
	collision_shape.set_deferred("disabled", true)


func _on_enemy_entered(enemy: Node2D) -> void:
	enemies_inside.push_back(enemy)


func _on_enemy_exited(enemy: Node2D) -> void:
	enemies_inside.erase(enemy)
	if enemy == closer_enemy:
		_update_closer_enemy()
