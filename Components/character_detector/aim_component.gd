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
func get_dir(from: Vector2 = Vector2.ZERO) -> AimResult:
	var res: AimResult

	if from == Vector2.ZERO:
		from = character.global_position

	if flags & FLAG_PREDICT_TRAJECTORY:
		var vector_to_target: Vector2 = (target.global_position - from)
		var projectile_time_to_target: float = vector_to_target.length() / projectile_speed
		var target_predicted_future_position: Vector2 = target.global_position + target.velocity * projectile_time_to_target

		var space_state: PhysicsDirectSpaceState2D = character.get_world_2d().direct_space_state
		# use global coordinates, not local to node
		var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(target.global_position, target_predicted_future_position, 1 + 16)
		var raycast_res: Dictionary = space_state.intersect_ray(query)
		if not raycast_res.is_empty():
			target_predicted_future_position = raycast_res.position + (target.global_position - raycast_res.position).normalized() * 4
		res = AimResult.new((target_predicted_future_position - character.global_position).normalized(), _is_trajectory_clear(from, target_predicted_future_position))
	else:
		res = AimResult.new((target.global_position - from).normalized(), _is_trajectory_clear(from, target.global_position))

	if flags & FLAG_REDUCE_PRECISION_WHEN_MOVING and character.velocity.length() > 10:
		res.dir = res.dir.rotated(randf_range(-0.2, 0.2))

	#res.make_read_only()
	return res


func _is_trajectory_clear(from: Vector2, to: Vector2) -> bool:
	var space_state: PhysicsDirectSpaceState2D = character.get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var exclude: Array[RID] = []
	exclude.push_back(character.get_rid())
	if character.has_node("HurtBox"):
		exclude.push_back((character.get_node("HurtBox") as HurtBox).get_rid())
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(from, to, 1 | character.collision_layer, exclude)
	query.collide_with_areas = true
	query.hit_from_inside  = true
	return space_state.intersect_ray(query).is_empty()



class AimResult:
	var dir: Vector2
	var clear: bool

	@warning_ignore("shadowed_variable")
	func _init(dir: Vector2, clear: bool) -> void:
		self.dir = dir
		self.clear = clear
