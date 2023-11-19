class_name PileOfBones extends Enemy


func spawn_skelebro() -> void:
	var skelebro: Enemy = load(Globals.ENEMIES["dagger_skelebro"].path).instantiate()
	skelebro.position = position + Vector2(16, 0).rotated(randf_range(0, 2*PI))
	room.add_enemy(skelebro)
