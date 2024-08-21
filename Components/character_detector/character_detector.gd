class_name CharacterDetector extends Area2D


var closer_enemy: Character = null

var characters_inside: Array[Character] = []

@onready var parent: Node2D = get_parent()
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
@onready var set_closer_enemy_timer: Timer = $SetCloserEnemyTimer


func _ready() -> void:
	assert(collision_shape, "CharacterDetector must have a CollisionShape2D")

	body_entered.connect(_on_enemy_entered)
	body_exited.connect(_on_enemy_exited)
	set_closer_enemy_timer.timeout.connect(_update_closer_enemy)


func get_direction() -> Vector2:
	push_error("You should override this function")
	return Vector2.ZERO


func _update_closer_enemy() -> void:
	var distance_to_closer_enemy: float = (closer_enemy.global_position - parent.global_position).length() if is_instance_valid(closer_enemy) else INF
	for enemy: Character in characters_inside:
		if enemy == closer_enemy:
			continue
		var distance_to_other_enemy: float = (enemy.global_position - parent.global_position).length()
		if distance_to_other_enemy < distance_to_closer_enemy:
			distance_to_closer_enemy = distance_to_other_enemy
			closer_enemy = enemy


func _enable() -> void:
	set_closer_enemy_timer.start()
	collision_shape.set_deferred("disabled", false)
	_update_closer_enemy()


func _disable() -> void:
	set_closer_enemy_timer.stop()
	collision_shape.set_deferred("disabled", true)


func _on_enemy_entered(character: Node2D) -> void:
	if character == get_parent() or character is not Character:
		return

	characters_inside.push_back(character)
	if closer_enemy == null:
		closer_enemy = character


func _on_enemy_exited(character: Node2D) -> void:
	if character == get_parent() or character is not Character:
		return

	characters_inside.erase(character)
	if characters_inside.is_empty():
		closer_enemy = null
	elif character == closer_enemy:
		_update_closer_enemy()
