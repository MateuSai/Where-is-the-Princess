class_name Weapons extends Node2D

var current_weapon: Weapon: set = set_current_weapon


func move(direction: Vector2) -> void:
	var prev_current_weap_rot: float = current_weapon.rotation
	current_weapon.move(direction)
	#if (prev_current_weap_rot > 0 and current_weapon.rotation < 0) or (prev_current_weap_rot < 0 and current_weapon.rotation > 0):
	if prev_current_weap_rot < 0 and current_weapon.rotation > 0:
		get_parent().move_child(self, -1)
	elif prev_current_weap_rot > 0 and current_weapon.rotation < 0:
		get_parent().move_child(self, 0)


func set_current_weapon(new_weapon: Weapon) -> void:
		if current_weapon != null and current_weapon is MeleeWeapon:
			var a: Array[Node2D] = []
			(current_weapon as MeleeWeapon).hitbox.exclude = a

		current_weapon = new_weapon

		if current_weapon is MeleeWeapon:
			var a: Array[Node2D] = [get_parent()]
			(current_weapon as MeleeWeapon).hitbox.exclude = a
