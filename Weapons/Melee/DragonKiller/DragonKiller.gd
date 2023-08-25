extends MeleeWeapon


func _spawn_shockwave_attack() -> void:
	var shockwave_attack: Hitbox = load("res://Weapons/Melee/DragonKiller/ShockwaveAttack.tscn").instantiate()
	shockwave_attack.position = global_position + Vector2.RIGHT.rotated(rotation) * 20
	get_tree().current_scene.add_child(shockwave_attack)
