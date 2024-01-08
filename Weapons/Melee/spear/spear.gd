class_name Spear extends MeleeWeapon

const ABILITY_EFFECT: PackedScene = preload("res://Weapons/Melee/spear/spear_ability_effect.tscn")


func _add_ability_effect() -> void:
	var effect: Hitbox = ABILITY_EFFECT.instantiate()
	effect.damage = ability_damage
	effect.knockback_force = ability_knockback
	effect.knockback_direction = Vector2.RIGHT.rotated(rotation)
	effect.rotation_degrees = -45
	effect.position = Vector2(20, -20)
	weapon_sprite.add_child(effect)
