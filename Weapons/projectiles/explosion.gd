class_name Explosion extends Hitbox


func _spawn_shrapnel() -> void:
	set_physics_process(false)

	$AnimationPlayer.pause()

	var num: int = randi() % 3 + 3
	var initial_rot: float = randf_range(0, 2*PI / (num - 1))
	var shrapnels: Array = []
	for i in num:
		var shrapnel: Sprite2D = load("res://Characters/Enemies/BombTribal/Shrapnel.tscn").instantiate()
		shrapnel.rotation = initial_rot + (2*PI / (num - 1)) * i + randf_range(-0.2, 0.2)
		add_child(shrapnel)
		move_child(shrapnel, 0)
		shrapnels.push_back(shrapnel)

	await get_tree().process_frame
	$AnimationPlayer.play()
	for shrapnel in shrapnels:
		shrapnel.get_node("AnimationPlayer").play("explode")
