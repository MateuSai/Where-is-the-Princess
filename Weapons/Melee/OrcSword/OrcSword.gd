extends MeleeWeapon


func _spawn_ability_effect() -> void:
	var intimidate_effect: Area2D = load("res://Weapons/Melee/OrcSword/IntimidateEffect.tscn").instantiate()
	intimidate_effect.position = global_position + Vector2.RIGHT.rotated(rotation) * 16
	get_tree().current_scene.add_child(intimidate_effect)
