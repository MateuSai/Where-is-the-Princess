class_name Bow extends RangedWeapon


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_attack") and not animation_player.is_playing():
		_charge()
	elif event.is_action_released("ui_attack"):
		if animation_player.is_playing() and animation_player.current_animation.begins_with("charge") and weapon_sprite.frame > 0:
			_bow_attack(animation_player.current_animation_position / animation_player.current_animation_length)
		elif weapon_sprite.frame > 0:
			_bow_attack(1.0)
		else:
			animation_player.play("RESET")

	if event.is_action_pressed("ui_weapon_ability") and has_active_ability() and not is_busy() and can_active_ability():
		_active_ability()


## Charge has a value between 0 and 1 where 1 is max charged
func _bow_attack(charge: float) -> void:
	projectile_speed = int(85 + 180 * charge) # The speed is truncated, a difference of 1 is very small anyway

	if is_equal_approx(charge, 1.0):
		damage += 1

	_attack()

	assert(animation_player.current_animation.begins_with("attack"))
	await animation_player.animation_finished # We wait until attack animation is finished

	if is_equal_approx(charge, 1.0):
		damage -= 1
