class_name SmallAxe extends MeleeWeapon

const EFFECT_SCENE: PackedScene = preload("res://Weapons/Melee/SmallAxe/SmallAxeEffect.tscn")


func _spawn_effect() -> void:
	var effect: Hitbox = EFFECT_SCENE.instantiate()
	effect.rotation = rotation #+ randf_range(-0.25, 0.25)
	effect.position = global_position + Vector2.RIGHT.rotated(effect.rotation) * 24
	get_tree().current_scene.add_child(effect)
