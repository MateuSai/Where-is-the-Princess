class_name Player extends Character

const DUST_SCENE: PackedScene = preload("res://Characters/Player/Dust.tscn")

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
@onready var weapons: Weapons = get_node("Weapons")
@onready var dust_position: Marker2D = get_node("DustPosition")

@onready var jump_animation_player: AnimationPlayer = get_node("JumpAnimationPlayer")
@onready var animation_tree: AnimationTree = get_node("AnimationTree")
@onready var animation_tree_state_machine: AnimationNodeStateMachinePlayback = get_node("AnimationTree").get("parameters/playback")


func _ready() -> void:
	weapon_picked_up.emit(weapons.get_child(0))

	_restore_previous_state()

	set_armor(KnightArmor.new())

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
	self.hp = SavedData.run_stats.hp


func _process(_delta: float) -> void:
	# sm.update(_delta)
	var mouse_direction: Vector2 = (get_global_mouse_position() - global_position).normalized()

	if mouse_direction.x > 0 and sprite.flip_h:
		sprite.flip_h = false
	elif mouse_direction.x < 0 and not sprite.flip_h:
		sprite.flip_h = true

	weapons.move(mouse_direction)


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

	weapons.get_input()

	if Input.is_action_just_pressed("ui_armor_ability") and armor.is_able_to_use_ability:
		armor.use_ability(self)


func add_coin() -> void:
	SavedData.coins += 1


func pick_up_passive_item(item: PassiveItem) -> void:
	passive_items.push_back(item)
	item.equip(self)
	emit_signal("passive_item_picked_up", item)


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


func jump() -> void:
	jump_animation_player.play("jump")
