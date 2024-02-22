extends MeleeWeapon

const GROUND_ATTACK_SCENE: PackedScene = preload("res://mods-unpacked/WekufuStudios-DemoMod/oriental_spear/oriental_spear_ability.tscn")

@onready var spear_point: Marker2D = $Node2D/WeaponSprite/SpearPoint


func _spawn_ground_attack() -> void:
	var amount: int = 10
	for i: int in amount:
		var ground_attack: Hitbox = GROUND_ATTACK_SCENE.instantiate()
		ground_attack.damage = data.ability_damage
		ground_attack.global_position = spear_point.global_position + Vector2.RIGHT.rotated((2*PI / amount) * (i + randf_range(-0.2, 0.2))) * randf_range(20, 36)
		get_tree().current_scene.add_child(ground_attack)
