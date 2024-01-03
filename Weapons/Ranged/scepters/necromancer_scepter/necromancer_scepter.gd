@icon("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Tromp the necromancer/tromp scepter.png")
class_name NecromancerScepter extends Scepter


func _spawn_projectile(_angle: float = 0.0, _amount: int = 1) -> Array[Projectile]:
	var position_to_spawn_skeleton: Vector2 = get_parent().get_parent().global_position + Vector2.RIGHT.rotated(rotation) * 64

	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(get_parent().get_parent().global_position, position_to_spawn_skeleton, 1 + 16)
	var raycast_res: Dictionary = space_state.intersect_ray(query)

	if not raycast_res.is_empty():
		position_to_spawn_skeleton = raycast_res.position + Vector2.RIGHT.rotated(rotation) * -16

	var necromancer_spawn: NecromancerSpawn = (load(projectile_scene_path) as PackedScene).instantiate()
	(get_parent().get_parent() as Enemy).room.add_child(necromancer_spawn)
	necromancer_spawn.global_position = position_to_spawn_skeleton

	return []
