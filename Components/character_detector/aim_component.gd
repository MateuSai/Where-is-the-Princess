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
		#var vector_to_target: Vector2 = (target.global_position - from)
		#var projectile_time_to_target: float = vector_to_target.length() / projectile_speed
		#var target_predicted_future_position: Vector2 = target.global_position + target.velocity * projectile_time_to_target
		var intersection_point_res: Dictionary = _get_intersection_point(from, target.global_position, projectile_speed, target.velocity)
		var predicted_position: Vector2 = intersection_point_res.result if intersection_point_res.solution else target.global_position
		#assert(target.mov_direction.length() <= 1)
		#var predicted_dir: Vector2 = (target.global_position * target.data.max_speed * target.mov_direction) / (from * projectile_speed)
		#print_debug(predicted_dir)

		var space_state: PhysicsDirectSpaceState2D = character.get_world_2d().direct_space_state
		# use global coordinates, not local to node
		var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(target.global_position, predicted_position, 1 + 16)
		var raycast_res: Dictionary = space_state.intersect_ray(query)
		if not raycast_res.is_empty():
			predicted_position = raycast_res.position + (target.global_position - raycast_res.position).normalized() * 4
		res = AimResult.new((predicted_position - from).normalized(), _is_trajectory_clear(from, predicted_position))
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

func _get_intersection_point(a: Vector2, b: Vector2, a_speed: float, b_velocity: Vector2) -> Dictionary:
	var a_to_b: Vector2 = b - a
	var a_to_b_dis: float = a_to_b.length()
	var alpha: float = a_to_b.angle_to(b_velocity)

	var r: float = b_velocity.length() / a_speed

	var quadratic_res: Dictionary = Globals.solve_quadratic(1 - r * r, 2 * r * a_to_b_dis * cos(alpha), -(a_to_b_dis * a_to_b_dis))
	if not quadratic_res.solution:
		return {
			"solution": false
		}

	var a_to_c_dis: float = max(quadratic_res.root_1, quadratic_res.root_2)
	var t: float = a_to_c_dis / a_speed
	var c: Vector2 = b + b_velocity * t

	return {
		"solution": true,
		"result": c
	}



class AimResult:
	var dir: Vector2
	var clear: bool

	@warning_ignore("shadowed_variable")
	func _init(dir: Vector2, clear: bool) -> void:
		self.dir = dir
		self.clear = clear
