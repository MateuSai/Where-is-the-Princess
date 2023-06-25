class_name Player extends Character

const DUST_SCENE: PackedScene = preload("res://Characters/Player/Dust.tscn")

enum {UP, DOWN}

var current_weapon: Node2D

signal weapon_switched(prev_index: int, new_index: int)
signal weapon_picked_up(weapon: Weapon)
signal weapon_droped(index: int)
signal weapon_condition_changed(weapon: Weapon, new_value: float)

var passive_items: Array[PassiveItem] = []
signal passive_item_picked_up(item: PassiveItem)

var armor: Armor = NoArmor.new() : set = set_armor

#var sm

# @onready var armor_sprite: Sprite2D = get_node("ArmorSprite")

@onready var parent: Node2D = get_parent()
@onready var weapons: Node2D = get_node("Weapons")
@onready var dust_position: Marker2D = get_node("DustPosition")

@onready var jump_animation_player: AnimationPlayer = get_node("JumpAnimationPlayer")
@onready var animation_tree: AnimationTree = get_node("AnimationTree")
@onready var animation_tree_state_machine: AnimationNodeStateMachinePlayback = get_node("AnimationTree").get("parameters/playback")


func _ready() -> void:
	emit_signal("weapon_picked_up", weapons.get_child(0))

	_restore_previous_state()

	# set_armor(KnightArmor.new())

#	var state_machine: StateMachine = StateMachine.new()
#	state_machine.add_state(State.new("idle", func() -> String:
#		if velocity.length() > 10:
#			return "move"
#		return ""
#	, func() -> void:
#		get_input()
#		move()
#		animation_tree.set("parameters/" + "idle" + "/blend_position", (get_global_mouse_position() - global_position).normalized().y)
#	, func() -> void:
#		animation_tree_state_machine.travel("idle")
#	))
#	state_machine.add_state(State.new("move", func() -> String:
#		if velocity.length() < 10:
#				return "idle"
#		return ""
#	, func() -> void:
#		get_input()
#		move()
#		animation_tree.set("parameters/" + "move" + "/blend_position", (get_global_mouse_position() - global_position).normalized().y)
#	, func() -> void:
#		animation_tree_state_machine.travel("move")
#	))
#
#	sm = state_machine
#	sm.set_current_state(sm.states["idle"])


func _restore_previous_state() -> void:
	self.hp = SavedData.hp
	for weapon_stat in SavedData.weapon_stats:
		var weapon: Weapon = load(weapon_stat.weapon_path).instantiate()
		weapon.stats = weapon_stat
		weapon.position = Vector2.ZERO
		weapons.add_child(weapon)
		weapon.hide()

		weapon.connect("condition_changed", _on_weapon_condition_changed)

		emit_signal("weapon_picked_up", weapon)
		emit_signal("weapon_switched", weapons.get_child_count() - 2, weapons.get_child_count() - 1)

	current_weapon = weapons.get_child(SavedData.equipped_weapon_index)
	current_weapon.show()

	emit_signal("weapon_switched", weapons.get_child_count() - 1, SavedData.equipped_weapon_index)


func _process(_delta: float) -> void:
	# sm.update(_delta)
	var mouse_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()

	if mouse_direction.x > 0 and sprite.flip_h:
		sprite.flip_h = false
	elif mouse_direction.x < 0 and not sprite.flip_h:
		sprite.flip_h = true

	current_weapon.move(mouse_direction)


func get_input() -> void:
	mov_direction = Vector2.ZERO
	if Input.is_action_pressed("ui_down"):
		mov_direction += Vector2.DOWN
	if Input.is_action_pressed("ui_left"):
		mov_direction += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		mov_direction += Vector2.RIGHT
	if Input.is_action_pressed("ui_up"):
		mov_direction += Vector2.UP

	if not current_weapon.is_busy():
		if Input.is_action_just_released("ui_previous_weapon"):
			_switch_weapon(UP)
		elif Input.is_action_just_released("ui_next_weapon"):
			_switch_weapon(DOWN)
		elif Input.is_action_just_pressed("ui_throw") and current_weapon.get_index() != 0:
			_drop_weapon()

	current_weapon.get_input()

	if Input.is_action_just_pressed("ui_armor_ability") and armor.is_able_to_use_ability:
		armor.use_ability(self)


func add_coin() -> void:
	SavedData.coins += 1


func pick_up_passive_item(item: PassiveItem) -> void:
	passive_items.push_back(item)
	item.equip(self)
	emit_signal("passive_item_picked_up", item)


func _switch_weapon(direction: int) -> void:
	var prev_index: int = current_weapon.get_index()
	var index: int = prev_index
	if direction == UP:
		index -= 1
		if index < 0:
			index = weapons.get_child_count() - 1
	else:
		index += 1
		if index > weapons.get_child_count() - 1:
			index = 0

	current_weapon.hide()
	current_weapon = weapons.get_child(index)
	current_weapon.show()
	SavedData.equipped_weapon_index = index

	emit_signal("weapon_switched", prev_index, index)


func pick_up_weapon(weapon: Weapon) -> void:
	SavedData.weapon_stats.append(weapon.stats)
	var prev_index: int = SavedData.equipped_weapon_index
	var new_index: int = weapons.get_child_count()
	SavedData.equipped_weapon_index = new_index
	weapon.get_parent().call_deferred("remove_child", weapon)
	weapons.call_deferred("add_child", weapon)
	weapon.set_deferred("owner", weapons)
	current_weapon.hide()
	current_weapon.cancel_attack()
	current_weapon = weapon

	weapon.connect("condition_changed", _on_weapon_condition_changed)

	emit_signal("weapon_picked_up", weapon)
	emit_signal("weapon_switched", prev_index, new_index)


func _drop_weapon() -> void:
	SavedData.weapons.remove_at(current_weapon.get_index() - 1)
	var weapon_to_drop: Node2D = current_weapon
	_switch_weapon(UP)

	emit_signal("weapon_droped", weapon_to_drop.get_index())

	weapons.call_deferred("remove_child", weapon_to_drop)
	get_parent().call_deferred("add_child", weapon_to_drop)
	weapon_to_drop.set_owner(get_parent())
	await weapon_to_drop.tree_entered
	weapon_to_drop.show()

	var throw_dir: Vector2 = (get_global_mouse_position() - position).normalized()
	weapon_to_drop.interpolate_pos(position, position + throw_dir * 50)


func _destroy_weapon() -> void:
	SavedData.weapon_stats.remove_at(current_weapon.get_index() - 1)
	var weapon_to_drop: Node2D = current_weapon
	_switch_weapon(UP)

	emit_signal("weapon_droped", weapon_to_drop.get_index())

	weapons.call_deferred("remove_child", weapon_to_drop)
	get_parent().call_deferred("add_child", weapon_to_drop)
	weapon_to_drop.queue_free()


func cancel_attack() -> void:
	current_weapon.cancel_attack()


func spawn_dust() -> void:
	var dust: Sprite2D = DUST_SCENE.instantiate()
	dust.position = dust_position.global_position
	parent.get_child(get_index() - 1).add_sibling(dust)


func switch_camera() -> void:
	var main_scene_camera: Camera2D = get_parent().get_node("Camera2D")
	main_scene_camera.position = position
	main_scene_camera.current = true
	get_node("Camera2D").current = false


func set_armor(new_armor: Armor) -> void:
	if new_armor == armor:
		return
	armor = new_armor
	sprite.texture = armor.sprite_sheet


func _on_weapon_condition_changed(weapon: Weapon, new_condition: float) -> void:
	assert(weapon == current_weapon)
	if new_condition == 0:
		_destroy_weapon()
	else:
		emit_signal("weapon_condition_changed", weapon, new_condition)


func jump() -> void:
	jump_animation_player.play("jump")
