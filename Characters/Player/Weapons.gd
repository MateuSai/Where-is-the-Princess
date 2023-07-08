class_name Weapons extends Node2D


signal weapon_switched(prev_index: int, new_index: int)
signal weapon_picked_up(weapon: Weapon)
signal weapon_droped(index: int)
signal weapon_condition_changed(weapon: Weapon, new_value: float)

var current_weapon: Weapon

enum {UP, DOWN}


func _ready() -> void:
	for weapon_stat in SavedData.run_stats.weapon_stats:
		var weapon: Weapon = load(weapon_stat.weapon_path).instantiate()
		weapon.stats = weapon_stat
		weapon.position = Vector2.ZERO
		add_child(weapon)
		weapon.hide()

		weapon.condition_changed.connect(_on_weapon_condition_changed)

		weapon_picked_up.emit(weapon)
		weapon_switched.emit(get_child_count() - 2, get_child_count() - 1)

	current_weapon = get_child(SavedData.run_stats.equipped_weapon_index)
	current_weapon.show()

	weapon_switched.emit(get_child_count() - 1, SavedData.run_stats.equipped_weapon_index)


func get_input() -> void:
	if not current_weapon.is_busy():
		if Input.is_action_just_released("ui_previous_weapon"):
			_switch_weapon(UP)
		elif Input.is_action_just_released("ui_next_weapon"):
			_switch_weapon(DOWN)
		elif Input.is_action_just_pressed("ui_throw") and current_weapon.get_index() != 0:
			_drop_weapon()

	current_weapon.get_input()


func move(mouse_direction: Vector2) -> void:
	var prev_current_weap_rot: float = current_weapon.rotation
	current_weapon.move(mouse_direction)
	#if (prev_current_weap_rot > 0 and current_weapon.rotation < 0) or (prev_current_weap_rot < 0 and current_weapon.rotation > 0):
	if prev_current_weap_rot < 0 and current_weapon.rotation > 0:
		get_parent().move_child(self, -1)
	elif prev_current_weap_rot > 0 and current_weapon.rotation < 0:
		get_parent().move_child(self, 0)
	# print(current_weapon.rotation)


func _switch_weapon(direction: int) -> void:
	var prev_index: int = current_weapon.get_index()
	var index: int = prev_index
	if direction == UP:
		index -= 1
		if index < 0:
			index = get_child_count() - 1
	else:
		index += 1
		if index > get_child_count() - 1:
			index = 0

	current_weapon.hide()
	current_weapon = get_child(index)
	current_weapon.show()
	SavedData.run_stats.equipped_weapon_index = index

	emit_signal("weapon_switched", prev_index, index)


func pick_up_weapon(weapon: Weapon) -> void:
	SavedData.run_stats.weapon_stats.append(weapon.stats)
	var prev_index: int = SavedData.run_stats.equipped_weapon_index
	var new_index: int = get_child_count()
	SavedData.run_stats.equipped_weapon_index = new_index
	weapon.get_parent().call_deferred("remove_child", weapon)
	call_deferred("add_child", weapon)
	# set_deferred("owner", self)
	current_weapon.hide()
	current_weapon.cancel_attack()
	current_weapon = weapon

	weapon.condition_changed.connect(_on_weapon_condition_changed)

	emit_signal("weapon_picked_up", weapon)
	emit_signal("weapon_switched", prev_index, new_index)


func _drop_weapon() -> void:
	var character_position: Vector2 = get_parent().position

	SavedData.run_stats.weapon_stats.remove_at(current_weapon.get_index() - 1)
	var weapon_to_drop: Node2D = current_weapon
	weapon_to_drop.condition_changed.disconnect(_on_weapon_condition_changed)
	_switch_weapon(UP)

	emit_signal("weapon_droped", weapon_to_drop.get_index())

	call_deferred("remove_child", weapon_to_drop)
	get_tree().current_scene.call_deferred("add_child", weapon_to_drop)
	# weapon_to_drop.set_owner(get_tree().current_scene)
	await weapon_to_drop.tree_entered
	weapon_to_drop.show()

	var throw_dir: Vector2 = (get_global_mouse_position() - character_position).normalized()
	weapon_to_drop.interpolate_pos(character_position, character_position + throw_dir * 50)


func throw_weapon() -> void:
	assert(current_weapon is ThrowableWeapon)

	SavedData.run_stats.weapon_stats.remove_at(current_weapon.get_index() - 1)
	var weapon_to_drop: Node2D = current_weapon
	weapon_to_drop.condition_changed.disconnect(_on_weapon_condition_changed)
	_switch_weapon(UP)

	emit_signal("weapon_droped", weapon_to_drop.get_index())

	var pos: Vector2 = weapon_to_drop.global_position
	remove_child(weapon_to_drop)

	weapon_to_drop.position = pos
	get_tree().current_scene.add_child(weapon_to_drop)
	weapon_to_drop.show()


func _destroy_weapon() -> void:
	SavedData.run_stats.weapon_stats.remove_at(current_weapon.get_index() - 1)
	var weapon_to_drop: Weapon = current_weapon
	_switch_weapon(UP)

	weapon_droped.emit(weapon_to_drop.get_index())

	var pos: Vector2 = weapon_to_drop.global_position
	#print(pos)
	call_deferred("remove_child", weapon_to_drop)
	get_tree().current_scene.call_deferred("add_child", weapon_to_drop)
	await get_tree().process_frame
	weapon_to_drop.position = pos
	weapon_to_drop.show()
	#print(str(weapon_to_drop.position) + "   " + str(weapon_to_drop.global_position))
	weapon_to_drop.destroy()


func cancel_attack() -> void:
	current_weapon.cancel_attack()


func _on_weapon_condition_changed(weapon: Weapon, new_condition: float) -> void:
	assert(weapon == current_weapon)
	if new_condition == 0:
		_destroy_weapon()
	else:
		emit_signal("weapon_condition_changed", weapon, new_condition)
