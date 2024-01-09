class_name Tromp extends Enemy

#const NECROMANCER_SPAWN: PackedScene = preload("res://Characters/necromancer_spawn/necromancer_spawn.tscn")


@onready var weapons: EnemyWeapons = $EnemyWeapons

func _process(_delta: float) -> void:
	weapons.move((target.global_position - global_position).normalized())


#func _spawn_skeletons(amount: int = 1) -> void:
	#for i: int in amount:
		#var necromancer_spawn: NecromancerSpawn = NECROMANCER_SPAWN.instantiate()
		#necromancer_spawn.position = position + Vector2.RIGHT.rotated(randf_range(0.0, 2*PI)) * randf_range(16, 64)
		#get_parent().add_child(necromancer_spawn)
