class_name PileOfBones extends Enemy


func _ready() -> void:
	super()

	can_move = false


func spawn_skelebro() -> void:
	var dagger_skelebro_scene: PackedScene = Globals.get_enemy_scene("dagger_skelebro")
	assert(dagger_skelebro_scene)
	var skelebro: Enemy = dagger_skelebro_scene.instantiate()
	skelebro.position = position + Vector2(16, 0).rotated(randf_range(0, 2*PI))
	room.add_enemy(skelebro)
