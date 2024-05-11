class_name Bow extends BowOrCrossbowWeapon

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_attack") and not animation_player.is_playing():
		Log.debug("Stating charge of bow")
		_charge()
	elif event.is_action_released("ui_attack"):
		if animation_player.is_playing() and get_current_animation().begins_with("charge") and is_charging() and weapon_sprite.frame > 0:
			_bow_attack(animation_player.current_animation_position / animation_player.current_animation_length)
		elif is_charging() and not animation_player.is_playing():
			_bow_attack(1.0)
		else:
			animation_player.play("RESET")

	if event.is_action_pressed("ui_weapon_ability") and has_active_ability() and not is_busy() and can_active_ability():
		_active_ability()

## Charge has a value between 0 and 1 where 1 is max charged
func _bow_attack(charge: float) -> void:
	if is_equal_approx(charge, 1.0):
		data.damage += 2
	elif charge > 0.6:
		data.damage += 1

	_attack()

	projectile_speed = int(data.normal_attack_projectile_speed * clamp((charge), 0.2, 1.0)) # The speed is truncated, a difference of 1 is very small anyway
	Log.debug("_bow_attack projectile_speed: " + str(projectile_speed))
	
	assert(get_current_animation().begins_with("attack"))
	await animation_player.animation_finished # We wait until attack animation is finished

	if is_equal_approx(charge, 1.0):
		data.damage -= 2
	elif charge > 0.6:
		data.damage -= 1

#
#func is_charging() -> bool:
	#return weapon_sprite.frame > 0
