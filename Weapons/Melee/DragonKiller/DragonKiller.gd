extends MeleeWeapon


func _spawn_shockwave_attack() -> void:
	var shockwave_attack: Hitbox = load("res://Weapons/Melee/DragonKiller/ShockwaveAttack.tscn").instantiate()
	shockwave_attack.position = global_position
	get_tree().current_scene.add_child(shockwave_attack)
