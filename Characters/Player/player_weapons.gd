class_name PlayerWeapons extends Weapons

signal weapon_switched(prev_index: int, new_index: int)
signal weapon_picked_up(weapon: Weapon)
signal weapon_droped(index: int)
signal weapon_condition_changed(weapon: Weapon, new_value: float)
signal weapon_status_inflicter_added(weapon: Weapon, status: StatusComponent.Status)

signal normal_attacked()
signal active_ability_used()

var max_weapons: int = 3

var extra_damage_when_weapon_breaks: int = 0
var block_throw: bool = false

enum {UP, DOWN}

var disabled: bool = false:
	set(new_value):
		disabled = new_value
		if disabled:
			hide()
			set_process_unhandled_input(false)
		else:
			show()
			set_process_unhandled_input(true)

@onready var player: Player = get_parent()

@onready var pick_up_weapon_cooldown_timer: Timer = $"../Timers/PickUpWeaponCooldownTimer"
@onready var equip_weapon_sound: AudioStreamPlayer = $"../EquipWeaponSound"

func _ready() -> void:
	super()

	player.oh_shit_im_out_of_stamina.connect(_on_oh_shit_im_out_of_stamina)

func load_previous_weapons() -> void:
	var dagger: MeleeWeapon = get_child(0)
	dagger.hide()
	dagger.set_process_unhandled_input(false)

	for weapon_stat: WeaponStats in SavedData.run_stats.weapon_stats:
		var weapon: Weapon = (load(weapon_stat.weapon_path) as PackedScene).instantiate()
		weapon.stats = weapon_stat
		weapon.position = Vector2.ZERO

		weapon.condition_changed.connect(_on_weapon_condition_changed)
		weapon.status_inflicter_added.connect(_on_weapon_status_inflicter_added)

		add_child(weapon)
		weapon.hide()

		weapon_picked_up.emit(weapon)
		weapon_switched.emit(get_child_count() - 2, get_child_count() - 1)

		weapon.load_modifiers()

	assert(get_child(SavedData.run_stats.equipped_weapon_index) is Weapon)
	Log.debug("equipped_weapon_index: " + str(SavedData.run_stats.equipped_weapon_index))
	set_current_weapon(get_child(SavedData.run_stats.equipped_weapon_index) as Weapon)
	current_weapon.show()

	weapon_switched.emit(get_child_count() - 1, SavedData.run_stats.equipped_weapon_index)

func _unhandled_input(event: InputEvent) -> void:
	if not current_weapon.is_busy():
		if event.is_action_released("ui_previous_weapon"):
			_switch_weapon(UP)
		elif event.is_action_released("ui_next_weapon"):
			_switch_weapon(DOWN)
		elif event.is_action_pressed("ui_throw_weapon") and current_weapon.get_index() != 0 and not block_throw:
			_throw_or_drop_weapon()

func move(direction: Vector2) -> void:
	if disabled:
		return

	super(direction)

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
	assert(get_child(index) is Weapon)
	set_current_weapon(get_child(index) as Weapon)
	current_weapon.show()
	SavedData.run_stats.equipped_weapon_index = index

	weapon_switched.emit(prev_index, index)

func pick_up_weapon(weapon: Weapon) -> void:
	assert(can_pick_up_weapon(weapon))
	#if weapon == null or not is_instance_valid(weapon) or weapon.is_queued_for_deletion() or not pick_up_weapon_cooldown_timer.is_stopped():
		#return

	pick_up_weapon_cooldown_timer.start()

	SavedData.run_stats.weapon_stats.append(weapon.stats)
	var prev_index: int = SavedData.run_stats.equipped_weapon_index
	var new_index: int = get_child_count()
	weapon.get_parent().remove_child.call_deferred(weapon)
	add_child.call_deferred(weapon)
	# set_deferred("owner", self)
	if current_weapon is Dagger:
		current_weapon.hide()
		current_weapon.cancel_attack()
		set_current_weapon(weapon)
		SavedData.run_stats.equipped_weapon_index = new_index
	else:
		weapon.hide()

	weapon.condition_changed.connect(_on_weapon_condition_changed)
	weapon.status_inflicter_added.connect(_on_weapon_status_inflicter_added)

	await get_tree().process_frame

	SavedData.discover_weapon_if_not_already(weapon.scene_file_path)
	SavedData.statistics.add_weapon_times_picked_up(weapon.weapon_id)

	weapon_picked_up.emit(weapon)
	if get_child(prev_index) is Dagger:
		weapon_switched.emit(prev_index, new_index)

	equip_weapon_sound.play()

func _throw_or_drop_weapon() -> void:
	if current_weapon is MeleeWeapon:
		current_weapon.start_throw_animations()
	else:
		_drop_weapon()

func _drop_weapon() -> void:
	pick_up_weapon_cooldown_timer.start()

	var character_position: Vector2 = player.global_position

	SavedData.run_stats.weapon_stats.remove_at(current_weapon.get_index() - 1)
	var weapon_to_drop: Weapon = current_weapon
	weapon_to_drop.condition_changed.disconnect(_on_weapon_condition_changed)
	weapon_to_drop.status_inflicter_added.disconnect(_on_weapon_status_inflicter_added)
	_switch_weapon(UP)

	weapon_droped.emit(weapon_to_drop.get_index())

	remove_child.call_deferred(weapon_to_drop)
	if (player.current_room):
		player.current_room.add_weapon_on_floor.call_deferred(weapon_to_drop, player.global_position - player.current_room.global_position)
	else:
		get_tree().current_scene.add_child.call_deferred(weapon_to_drop)
	# weapon_to_drop.set_owner(get_tree().current_scene)
	await weapon_to_drop.tree_entered
	weapon_to_drop.show()

	var throw_dir: Vector2 = (get_global_mouse_position() - character_position).normalized()
	weapon_to_drop.interpolate_pos(weapon_to_drop.position, weapon_to_drop.position + throw_dir * 50)

func steal_weapon() -> Weapon:
	assert(get_child_count() > 1)

	SavedData.run_stats.weapon_stats.remove_at(current_weapon.get_index() - 1)
	var weapon_to_steal: Weapon = current_weapon
	weapon_to_steal.condition_changed.disconnect(_on_weapon_condition_changed)
	weapon_to_steal.status_inflicter_added.disconnect(_on_weapon_status_inflicter_added)
	_switch_weapon(UP)

	weapon_droped.emit(weapon_to_steal.get_index())

	remove_child(weapon_to_steal)

	return weapon_to_steal

func throw_weapon() -> void:
	assert(current_weapon is MeleeWeapon)

	SavedData.run_stats.weapon_stats.remove_at(current_weapon.get_index() - 1)
	var weapon_to_drop: Weapon = current_weapon
	weapon_to_drop.condition_changed.disconnect(_on_weapon_condition_changed)
	weapon_to_drop.status_inflicter_added.disconnect(_on_weapon_status_inflicter_added)
	_switch_weapon(UP)

	weapon_droped.emit(weapon_to_drop.get_index())

	var pos: Vector2 = weapon_to_drop.global_position
	remove_child(weapon_to_drop)

	weapon_to_drop.position = pos
	weapon_to_drop.hitbox.exclude = character.get_exclude_bodies()
	if (player.current_room):
		player.current_room.add_weapon_on_floor(weapon_to_drop, player.global_position - player.current_room.global_position)
	else:
		get_tree().current_scene.add_child(weapon_to_drop)
	#get_tree().current_scene.add_child(weapon_to_drop)
	weapon_to_drop.show()

func _destroy_weapon() -> void:
	SavedData.run_stats.weapon_stats.remove_at(current_weapon.get_index() - 1)
	var weapon_to_drop: Weapon = current_weapon
	_switch_weapon(UP)

	weapon_droped.emit(weapon_to_drop.get_index())

	var pos: Vector2 = weapon_to_drop.global_position
	#print(pos)
	remove_child.call_deferred(weapon_to_drop)
	get_tree().current_scene.add_child.call_deferred(weapon_to_drop)
	await get_tree().process_frame
	weapon_to_drop.position = pos
	weapon_to_drop.show()
	#print(str(weapon_to_drop.position) + "   " + str(weapon_to_drop.global_position))
	weapon_to_drop.destroy()

func cancel_attack() -> void:
	current_weapon.cancel_attack()

func can_current_weapon_pick_up_soul() -> bool:
	return current_weapon.can_pick_up_soul()

func add_soul_to_current_weapon() -> void:
	current_weapon.stats.souls += 1

func _on_weapon_condition_changed(weapon: Weapon, new_condition: float) -> void:
	#assert(weapon == current_weapon)
	if weapon != current_weapon:
		return

	if new_condition <= 0:
		_destroy_weapon()
	else:
		weapon_condition_changed.emit(weapon, new_condition)

func _on_weapon_status_inflicter_added(weapon: Weapon, status: StatusComponent.Status) -> void:
	weapon_status_inflicter_added.emit(weapon, status)

func set_current_weapon(new_weapon: Weapon) -> void:
	if current_weapon != null:
		current_weapon.set_process_unhandled_input(false)
		current_weapon.used_normal_attack.disconnect(_on_normal_attack)
		current_weapon.used_active_ability.disconnect(_on_active_ability)
		current_weapon.charge_animation_still_executing.disconnect(_on_charge_animation_still_executing)
		if current_weapon is Crossbow:
			(current_weapon as Crossbow).reloaded.disconnect(_on_reloaded)

	super(new_weapon)

	current_weapon.set_process_unhandled_input(true)
	current_weapon.used_normal_attack.connect(_on_normal_attack)
	current_weapon.used_active_ability.connect(_on_active_ability)
	current_weapon.charge_animation_still_executing.connect(_on_charge_animation_still_executing)
	if current_weapon is Crossbow:
		(current_weapon as Crossbow).reloaded.connect(_on_reloaded)

	# This shit does not work
	# SavedData.run_stats.equipped_weapon_index = current_weapon.get_index()

func can_pick_up_weapon(weapon_to_pick: Weapon) -> bool:
	return get_child_count() < max_weapons and weapon_to_pick != null and is_instance_valid(weapon_to_pick) and not weapon_to_pick.is_queued_for_deletion() and pick_up_weapon_cooldown_timer.is_stopped() and not current_weapon.is_busy()

func _on_normal_attack() -> void:
	player.consume_stamina(current_weapon.data.stamina_cost_per_normal_attack, current_weapon.animation_player.current_animation_length)

	normal_attacked.emit()

func _on_active_ability() -> void:
	player.consume_stamina(current_weapon.data.stamina_to_activate_active_ability, current_weapon.animation_player.current_animation_length)

	active_ability_used.emit()

func _on_charge_animation_still_executing() -> void:
	player.consume_stamina(0.7)

func _on_reloaded() -> void:
	player.consume_stamina(current_weapon.data.reload_stamina, current_weapon.animation_player.current_animation_length)

func _on_oh_shit_im_out_of_stamina() -> void:
	if current_weapon.is_charging():
		current_weapon.cancel_attack()
