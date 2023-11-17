class_name EnemyWeapons extends Node2D

@onready var current_weapon: Weapon = get_child(0)


func move(mouse_direction: Vector2) -> void:
#	if disabled:
#		return

	var prev_current_weap_rot: float = current_weapon.rotation
	current_weapon.move(mouse_direction)
	#if (prev_current_weap_rot > 0 and current_weapon.rotation < 0) or (prev_current_weap_rot < 0 and current_weapon.rotation > 0):
	if prev_current_weap_rot < 0 and current_weapon.rotation > 0:
		get_parent().move_child(self, -1)
	elif prev_current_weap_rot > 0 and current_weapon.rotation < 0:
		get_parent().move_child(self, 0)


func is_busy() -> bool:
	return current_weapon.is_busy()


func attack() -> void:
	assert(not is_busy())

	current_weapon._attack()
