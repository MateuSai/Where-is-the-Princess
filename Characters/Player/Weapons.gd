class_name Weapons extends Node2D


signal weapon_switched(prev_index: int, new_index: int)
signal weapon_picked_up(weapon: Weapon)
signal weapon_droped(index: int)
signal weapon_condition_changed(weapon: Weapon, new_value: float)
signal weapon_status_inflicter_added(weapon: Weapon, status: StatusComponent.Status)

var current_weapon: Weapon: set = set_current_weapon

var max_weapons: int = 4

enum {UP, DOWN}


func load_previous_weapons() -> void:
	get_child(0).hide()
	get_child(0).set_process_unhandled_input(false)

	for weapon_stat in SavedData.run_stats.weapon_stats:
		var weapon: Weapon = load(weapon_stat.weapon_path).instantiate()
		weapon.stats = weapon_stat
		weapon.position = Vector2.ZERO

		weapon.condition_changed.connect(_on_weapon_condition_changed)
		weapon.status_inflicter_added.connect(_on_weapon_status_inflicter_added)

		add_child(weapon)
		weapon.hide()

		weapon_picked_up.emit(weapon)
		weapon_switched.emit(get_child_count() - 2, get_child_count() - 1)

	set_current_weapon(get_child(SavedData.run_stats.equipped_weapon_index))
	current_weapon.show()

	weapon_switched.emit(get_child_count() - 1, SavedData.run_stats.equipped_weapon_index)


func _unhandled_input(event: InputEvent) -> void:
	if not current_weapon.is_busy():
		if event.is_action_released("ui_previous_weapon"):
			_switch_weapon(UP)
		elif event.is_action_released("ui_next_weapon"):
			_switch_weapon(DOWN)
		elif event.is_action_pressed("ui_throw") and current_weapon.get_index() != 0:
			_drop_weapon()


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
	set_current_weapon(get_child(index))
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
	set_current_weapon(weapon)

	weapon.condition_changed.connect(_on_weapon_condition_changed)
	weapon.status_inflicter_added.connect(_on_weapon_status_inflicter_added)

	await get_tree().process_frame

	weapon_picked_up.emit(weapon)
	weapon_switched.emit(prev_index, new_index)


func _drop_weapon() -> void:
	var character_position: Vector2 = get_parent().position

	SavedData.run_stats.weapon_stats.remove_at(current_weapon.get_index() - 1)
	var weapon_to_drop: Weapon = current_weapon
	weapon_to_drop.condition_changed.disconnect(_on_weapon_condition_changed)
	weapon_to_drop.status_inflicter_added.disconnect(_on_weapon_status_inflicter_added)
	_switch_weapon(UP)

	weapon_droped.emit(weapon_to_drop.get_index())

	call_deferred("remove_child", weapon_to_drop)
	get_tree().current_scene.call_deferred("add_child", weapon_to_drop)
	# weapon_to_drop.set_owner(get_tree().current_scene)
	await weapon_to_drop.tree_entered
	weapon_to_drop.show()

	var throw_dir: Vector2 = (get_global_mouse_position() - character_position).normalized()
	weapon_to_drop.interpolate_pos(character_position, character_position + throw_dir * 50)


func throw_weapon() -> void:
	assert(current_weapon is MeleeWeapon)

	SavedData.run_stats.weapon_stats.remove_at(current_weapon.get_index() - 1)
	var weapon_to_drop: Node2D = current_weapon
	weapon_to_drop.condition_changed.disconnect(_on_weapon_condition_changed)
	weapon_to_drop.status_inflicter_added.disconnect(_on_weapon_status_inflicter_added)
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


func add_soul_to_current_weapon() -> void:
	current_weapon.stats.souls += 1


func _on_weapon_condition_changed(weapon: Weapon, new_condition: float) -> void:
	assert(weapon == current_weapon)
	if new_condition <= 0:
		_destroy_weapon()
	else:
		weapon_condition_changed.emit(weapon, new_condition)


func _on_weapon_status_inflicter_added(weapon: Weapon, status: StatusComponent.Status) -> void:
	weapon_status_inflicter_added.emit(weapon, status)


func set_current_weapon(new_weapon: Weapon) -> void:
		if current_weapon != null:
			current_weapon.set_process_unhandled_input(false)
		current_weapon = new_weapon
		current_weapon.set_process_unhandled_input(true)


func can_pick_up_weapons() -> bool:
	return get_child_count() < max_weapons
