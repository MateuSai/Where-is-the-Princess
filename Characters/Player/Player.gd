class_name Player extends Character

const DUST_SCENE: PackedScene = preload("res://Characters/Player/Dust.tscn")

#signal weapon_switched(prev_index: int, new_index: int)
#signal weapon_picked_up(weapon: Weapon)
#signal weapon_droped(index: int)
#signal weapon_condition_changed(weapon: Weapon, new_value: float)
#signal weapon_status_inflicter_added(weapon: Weapon, status: StatusComponent.Status)

signal temporal_passive_item_picked_up(item: TemporalPassiveItem)
signal temporal_passive_item_unequiped(item: TemporalPassiveItem)
signal permanent_passive_item_picked_up(item: PermanentPassiveItem)

var armor: Armor = null : set = set_armor

var mouse_direction: Vector2

var can_move: bool = true

var throw_piercing: int = 1

var rotating_items: Array[Node2D] = []

#var sm

# @onready var armor_sprite: Sprite2D = get_node("ArmorSprite")

@onready var parent: Node2D = get_parent()
@onready var weapons: Weapons = get_node("Weapons")
@onready var dust_position: Marker2D = get_node("DustPosition")

@onready var jump_animation_player: AnimationPlayer = get_node("JumpAnimationPlayer")


func _ready() -> void:
	super()

	weapons.weapon_picked_up.emit(weapons.get_child(0))
	weapons.load_previous_weapons()

	_restore_previous_state()

	#set_armor(NoArmor.new())
	#set_armor(KnightArmor.new())
	if SavedData.run_stats.armor == null:
		set_armor(NoArmor.new())
	else:
		set_armor(SavedData.run_stats.armor)

	life_component.hp_changed.connect(func(new_hp: int):
		SavedData.run_stats.hp = new_hp
		if new_hp == 0:
			SceneTransistor.start_transition_to("res://BaseCamp.tscn")
			SavedData.reset_data()
	)

#	weapons.weapon_switched.connect(func(prev_index: int, new_index: int): weapon_switched.emit(prev_index, new_index))
#	weapons.weapon_picked_up.connect(func(weapon: Weapon): weapon_picked_up.emit(weapon))
#	weapons.weapon_droped.connect(func(index: int): weapon_droped.emit(index))
#	weapons.weapon_condition_changed.connect(func(weapon: Weapon, new_value: float):
#		weapon_condition_changed.emit(weapon, new_value)
#	)
#	weapons.weapon_status_inflicter_added.connect(func(weapon: Weapon, status: StatusComponent.Status):
#		weapon_status_inflicter_added.emit(weapon, status)
#	)

	Globals.player = self

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
	life_component.hp = SavedData.run_stats.hp
	for permanent_passive_item in SavedData.run_stats.permanent_passive_items:
		pick_up_passive_item(permanent_passive_item)
	for temporal_passive_item in SavedData.run_stats.temporal_passive_items:
		pick_up_passive_item(temporal_passive_item)


func _exit_tree() -> void:
	Globals.player = null


func _process(_delta: float) -> void:
	# sm.update(_delta)
	mouse_direction = (get_global_mouse_position() - global_position).normalized()

	if mouse_direction.x > 0 and sprite.flip_h:
		sprite.flip_h = false
	elif mouse_direction.x < 0 and not sprite.flip_h:
		sprite.flip_h = true

	weapons.move(mouse_direction)


func get_input() -> void:
	mov_direction = Vector2.ZERO
	if can_move:
		if Input.is_action_pressed("ui_down"):
			mov_direction += Vector2.DOWN
		if Input.is_action_pressed("ui_left"):
			mov_direction += Vector2.LEFT
		if Input.is_action_pressed("ui_right"):
			mov_direction += Vector2.RIGHT
		if Input.is_action_pressed("ui_up"):
			mov_direction += Vector2.UP

	if Input.is_action_just_pressed("ui_armor_ability") and armor.is_able_to_use_ability:
		armor.use_ability(self)


func add_coin() -> void:
	SavedData.run_stats.coins += 1


func _on_damage_taken(dam: int, dir: Vector2, force: int) -> void:
	super(dam, dir, force)

	if not armor is NoArmor:
		armor.condition -= dam
		if armor.condition <= 0:
			var particles: GPUParticles2D = load("res://Shaders and Particles/DestroyParticles.tscn").instantiate()
			particles.position += Vector2.UP * 6
			add_child(particles)
			set_armor(NoArmor.new())


func pick_up_passive_item(item: PassiveItem) -> void:
	if item is PermanentPassiveItem:
		item.equip(self)
		if not SavedData.run_stats.permanent_passive_items.has(item):
			SavedData.run_stats.permanent_passive_items.push_back(item)
		permanent_passive_item_picked_up.emit(item)
	elif item is WeaponModifier:
		item.equip(weapons.current_weapon)
		weapons.current_weapon.add_weapon_modifier(item)
	else: # TemporalPassiveItem
		item.equip(self)
		if not SavedData.run_stats.temporal_passive_items.has(item):
			SavedData.run_stats.temporal_passive_items.push_back(item)
		temporal_passive_item_picked_up.emit(item)


func unequip_passive_item(item: PassiveItem) -> void:
	assert(item is TemporalPassiveItem)
	item.unequip(self)
	temporal_passive_item_unequiped.emit(item)
	SavedData.run_stats.temporal_passive_items.erase(item)


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
	if armor:
		armor.unequip(self)
	armor = new_armor
	armor.equip(self)
	SavedData.run_stats.armor = armor
	sprite.texture = armor.sprite_sheet


func jump() -> void:
	jump_animation_player.play("jump")


func add_rotating_item(node: Node2D) -> void:
	add_child(node)
	rotating_items.push_back(node)

	var rot: float = 2*PI / rotating_items.size()
	for i in rotating_items.size():
		rotating_items[i].rotation = rot * i


func remove_rotating_item(node: Node2D) -> void:
	rotating_items.erase(node)
	node.queue_free()

	var rot: float = 2*PI / rotating_items.size()
	for i in rotating_items.size():
		rotating_items[i].rotation = rot * i
