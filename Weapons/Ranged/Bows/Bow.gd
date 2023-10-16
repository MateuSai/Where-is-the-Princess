class_name Bow extends RangedWeapon


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_attack") and not animation_player.is_playing():
		_charge()
	elif event.is_action_released("ui_attack"):
		if animation_player.is_playing() and animation_player.current_animation.begins_with("charge") and weapon_sprite.frame > 0:
			_attack()
		elif weapon_sprite.frame > 0:
			_attack()
		else:
			animation_player.play("RESET")

	if event.is_action_pressed("ui_weapon_ability") and has_active_ability() and not is_busy() and can_active_ability():
		_active_ability()
