@icon("res://Art/16x16 Pixel Art Roguellike Sewer Pack/Enemies/Tromp the necromancer/tromp scepter.png")
class_name NecromancerScepter extends Scepter

const MAX_NUM_SKELETONS_ALIVE: int = 4

const STEAL_LIFE_ATTACK_SCENE: PackedScene = preload("res://Characters/Enemies/necro_tromp/tromp_steal_life_attack.tscn")

var num_skeletons_alive: int = 0


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

	num_skeletons_alive += 1
	necromancer_spawn.enemy_spawned.connect(func(enemy: Enemy) -> void:
		enemy.life_component.died.connect(func() -> void:
			num_skeletons_alive -= 1
		)
	)

	return []


func _spawn_steal_life_attack() -> void:
	if get_tree() == null:
		return

	var steal_life_attack: TrompStealLifeAttack = STEAL_LIFE_ATTACK_SCENE.instantiate()
	steal_life_attack.tromp = get_parent().get_parent()
	steal_life_attack.global_position = (get_parent().get_parent() as Enemy).target.global_position
	get_tree().current_scene.add_child(steal_life_attack)


func _spawn_magic_bouncing_projectile() -> void:
	var small_magic_bouncing_projectile_scene: PackedScene = load("res://Weapons/projectiles/magic_bouncing_projectile/magic_bouncing_projectile.tscn")
	var dir: Vector2 = Vector2.RIGHT.rotated(rotation)
	var small_magic_bouncing_projectile: MagicBouncingProjectile = small_magic_bouncing_projectile_scene.instantiate()
	get_tree().current_scene.add_child(small_magic_bouncing_projectile)
	small_magic_bouncing_projectile.launch(spawn_projectile_pos.global_position, dir,  140, true)
