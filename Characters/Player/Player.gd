class_name Player extends Character

const DUST_SCENE: PackedScene = preload("res://Characters/Player/Dust.tscn")

signal weapon_switched(prev_index: int, new_index: int)
signal weapon_picked_up(weapon: Weapon)
signal weapon_droped(index: int)
signal weapon_condition_changed(weapon: Weapon, new_value: float)

var permanent_passive_items: Array[PermanentPassiveItem] = []
var temporal_passive_items: Array[TemporalPassiveItem] = []
signal temporal_passive_item_picked_up(item: TemporalPassiveItem)
signal temporal_passive_item_unequiped(index: int)
signal permanent_passive_item_picked_up(item: PermanentPassiveItem)

var armor: Armor = null : set = set_armor

var mouse_direction: Vector2

var can_move: bool = true

#var sm

# @onready var armor_sprite: Sprite2D = get_node("ArmorSprite")

@onready var parent: Node2D = get_parent()
@onready var weapons: Weapons = get_node("Weapons")
@onready var dust_position: Marker2D = get_node("DustPosition")

@onready var jump_animation_player: AnimationPlayer = get_node("JumpAnimationPlayer")


func _ready() -> void:
	super()

	weapon_picked_up.emit(weapons.get_child(0))

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
			SceneTransistor.start_transition_to("res://Game.tscn")
			SavedData.reset_data()
	)

	weapons.weapon_switched.connect(func(prev_index: int, new_index: int): weapon_switched.emit(prev_index, new_index))
	weapons.weapon_picked_up.connect(func(weapon: Weapon): weapon_picked_up.emit(weapon))
	weapons.weapon_droped.connect(func(index: int): weapon_droped.emit(index))
	weapons.weapon_condition_changed.connect(func(weapon: Weapon, new_value: float): weapon_condition_changed.emit(weapon, new_value))

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

	weapons.get_input()

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
	item.equip(self)
	if item is PermanentPassiveItem:
		permanent_passive_items.push_back(item)
		permanent_passive_item_picked_up.emit(item)
	else: # TemporalPassiveItem
		temporal_passive_items.push_back(item)
		temporal_passive_item_picked_up.emit(item)


func unequip_passive_item(item: PassiveItem) -> void:
	assert(item is TemporalPassiveItem)
	item.unequip(self)
	temporal_passive_item_unequiped.emit(temporal_passive_items.find(item))
	temporal_passive_items.erase(item)


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
