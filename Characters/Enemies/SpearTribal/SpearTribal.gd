class_name SpearTribal extends Enemy

const MAX_DISTANCE_TO_PLAYER: int = 24
const MIN_DISTANCE_TO_PLAYER: int = 8
const MIN_DISTANCE_TO_CHARGE: int = 64

var distance_to_player: float

@onready var spear_pivot: Node2D = $SpearPivot
@onready var spear_hitbox: Hitbox = $SpearPivot/Sprite2D/Hitbox
@onready var aim_ray_cast: RayCast2D = $AimRayCast


func point_to_player() -> void:
	var vector_to_target: Vector2 = (player.position - global_position)
	spear_pivot.rotation = vector_to_target.angle()

	if vector_to_target.x < 0:
		spear_pivot.scale.y = -1
	else:
		spear_pivot.scale.y = 1


func _on_PathTimer_timeout() -> void:
	if is_instance_valid(player):
		var vector_to_player: Vector2 = (player.position - global_position)
		aim_ray_cast.target_position = vector_to_player
		distance_to_player = vector_to_player.length()
		if distance_to_player > MAX_DISTANCE_TO_PLAYER:
			_get_path_to_player()
		elif distance_to_player < MIN_DISTANCE_TO_PLAYER:
			_get_path_to_move_away_from_player()
	else:
		mov_direction = Vector2.ZERO


func _get_path_to_move_away_from_player() -> void:
	var dir: Vector2 = (global_position - player.position).normalized()
	navigation_agent.target_position = global_position + dir * 100


func _update_spear_hitbox() -> void:
	spear_hitbox.knockback_direction = Vector2.RIGHT.rotated(spear_pivot.rotation)
