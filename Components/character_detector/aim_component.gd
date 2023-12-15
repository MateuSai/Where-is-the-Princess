class_name AimComponent extends Node

var target: Character:
	get:
		return character.target
var projectile_speed: int:
	get:
		return character.projectile_speed

const FLAG_PREDICT_TRAJECTORY: int = 1
const FLAG_REDUCE_PRECISION_WHEN_MOVING: int = 2
@export_flags("Predict trajectory", "Reduce precision when moving") var flags: int = 0

@onready var character: Character = get_parent()


## Returns a dictionary containing the aim direction to the target as `dir`. It also contains `clear` that contains a bool indicating if the trajectory is clear of obstacles
func get_dir() -> Dictionary:
	var res: Dictionary = {}

	if flags & FLAG_PREDICT_TRAJECTORY:
		var vector_to_target: Vector2 = (target.global_position - character.global_position)
		var projectile_time_to_target: float = vector_to_target.length() / projectile_speed
		var target_predicted_future_position: Vector2 = target.global_position + target.velocity * projectile_time_to_target
		res["dir"] = (target_predicted_future_position - character.global_position).normalized()
		res["clear"] = _is_trajectory_clear(target_predicted_future_position)
	else:
		res["dir"] = (target.global_position - character.global_position).normalized()
		res["clear"] = _is_trajectory_clear(target.global_position)

	if flags & FLAG_REDUCE_PRECISION_WHEN_MOVING and character.velocity.length() > 10:
		res["dir"] = res["dir"].rotated(randf_range(-0.2, 0.2))

	res.make_read_only()
	return res


func _is_trajectory_clear(to: Vector2) -> bool:
	var space_state: PhysicsDirectSpaceState2D = character.get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(character.global_position, to, 1)
	return not space_state.intersect_ray(query).is_empty()
