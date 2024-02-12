class_name RoyalCrossbow extends "res://Weapons/Ranged/crossbows/crossbow.gd"

const BOMB_SCENE: PackedScene = preload("res://Weapons/projectiles/bombs/Bomb.tscn")


func _spawn_bomb() -> void:
	var bomb: Bomb = BOMB_SCENE.instantiate()
	get_tree().current_scene.add_child(bomb)
	bomb.position = spawn_projectile_pos.global_position
	bomb.dir = Vector2.RIGHT.rotated(rotation)
	bomb.speed = 250
	bomb.dam = ability_damage
	bomb.destroy_on_collide_with_world = true
	bomb.set_physics_process(true)
