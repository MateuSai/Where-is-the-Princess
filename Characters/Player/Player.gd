class_name Player extends Character

#signal weapon_switched(prev_index: int, new_index: int)
#signal weapon_picked_up(weapon: Weapon)
#signal weapon_droped(index: int)
#signal weapon_condition_changed(weapon: Weapon, new_value: float)
#signal weapon_status_inflicter_added(weapon: Weapon, status: StatusComponent.Status)

signal temporal_passive_item_picked_up(item: TemporalPassiveItem)
signal temporal_passive_item_unequiped(item: TemporalPassiveItem)
signal permanent_passive_item_picked_up(item: PermanentPassiveItem)

var armor: Armor = NoArmor.new() : set = set_armor
signal armor_changed(new_armor: Armor)

var mouse_direction: Vector2
# Controller constants
const AIM_MIN_DISTANCE: int = 45
const AIM_MULTIPLIER: int = 140
var previous_aim_pos: Vector2 = Vector2.ZERO

var throw_piercing: int = 1
var extra_fire_damage: int = 0
var attract_souls_even_on_combat: bool = false
var armor_ability_recharge_time_reduction: float = 0.0:
	set(new_value):
		armor_ability_recharge_time_reduction = clamp(new_value, 0.0, 0.95)
signal shop_discount_changed(new_value: float)
var shop_discount: float = 0.0: ## 0 = no discount, 1 = free
	set(new_value):
		shop_discount = new_value
		shop_discount_changed.emit(shop_discount)
## 0 = normal degradation, 1 = no degradation. This value can't be higher than 0.9
var weapon_degradation_reduction: float = 0.0:
	set(new_value):
		weapon_degradation_reduction = clamp(new_value, 0.0, 0.9)
#var projectiles_homing_degree: float = 0.05

var rotating_items: Array[Node2D] = []

#var sm

# @onready var armor_sprite: Sprite2D = get_node("ArmorSprite")

@onready var weapons: PlayerWeapons = get_node("Weapons")
@onready var camera: Camera2D = $Camera2D

@onready var jump_animation_player: AnimationPlayer = get_node("JumpAnimationPlayer")

@onready var auto_aim_area: AutoAimArea = $AutoAimArea

@onready var armor_effect_timer: Timer = $Timers/ArmorEffectTimer
@onready var armor_recharge_timer: Timer = $Timers/ArmorRechargeTimer
@onready var mirage_timer: Timer = $Timers/MirageTimer

@onready var mirage: TextureRect = $UI/Mirage

@onready var equip_armor_sound: AudioStreamPlayer = $EquipArmorSound
@onready var eat_sound: AudioStreamPlayer = $EatSound
@onready var burp_sound: AudioStreamPlayer = $BurpSound

@onready var acid_bar: TextureProgressBar = $AcidBar


func _ready() -> void:
	super()

	disable_mirage()

	acid_bar.hide()

	mirage_timer.timeout.connect(disable_mirage)

	weapons.weapon_picked_up.emit(weapons.get_child(0))
	weapons.load_previous_weapons()

	_restore_previous_state()

	#set_armor(NoArmor.new())
	#set_armor(KnightArmor.new())
	if SavedData.run_stats.armor == null:
		set_armor(NoArmor.new())
	else:
		set_armor(SavedData.run_stats.armor)

	life_component.hp_changed.connect(func(new_hp: int) -> void:
		SavedData.run_stats.hp = new_hp
		if new_hp == 0:
			SceneTransistor.start_transition_to("res://BaseCamp.tscn")
			SavedData.reset_run_stats()
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

	eat_sound.finished.connect(burp_sound.play)


func _restore_previous_state() -> void:
	life_component.hp = SavedData.run_stats.hp
	for permanent_passive_item: PermanentPassiveItem in SavedData.run_stats.permanent_passive_items:
		pick_up_passive_item(permanent_passive_item)
	for temporal_passive_item: TemporalPassiveItem in SavedData.run_stats.temporal_passive_items:
		pick_up_passive_item(temporal_passive_item)


func _exit_tree() -> void:
	Globals.player = null


func _process(_delta: float) -> void:
	#camera.position = camera.position.lerp(position, 0.08)

	# sm.update(_delta)
	if Settings.auto_aim or is_equal_approx(Settings.aim_help, 1.0):
		mouse_direction = auto_aim_area.get_direction()
	else:
		if Globals.mode == Globals.Mode.CONTROLLER:
#			mouse_direction = _controller_aim()
			_controller_aim()
#		else:
		mouse_direction = (get_global_mouse_position() - global_position).normalized()

		if Settings.aim_help > 0.0:
			var closer_enemy_direction: Vector2 = auto_aim_area.get_direction_using_dir(mouse_direction, PI * Settings.aim_help)
			if closer_enemy_direction != Vector2.ZERO:
				mouse_direction = closer_enemy_direction

	if mouse_direction.x > 0 and sprite.flip_h:
		sprite.flip_h = false
	elif mouse_direction.x < 0 and not sprite.flip_h:
		sprite.flip_h = true

	weapons.move(mouse_direction)


func _controller_aim() -> void:
	var window_size: Vector2 = get_viewport().size
	var weapons_pos_in_screen: Vector2 = weapons.get_global_transform_with_canvas().origin
	var aim_pos: Vector2 = weapons_pos_in_screen + Input.get_vector("ui_aim_left", "ui_aim_right", "ui_aim_up", "ui_aim_down") * window_size.normalized() * AIM_MULTIPLIER
	aim_pos.x = clamp(aim_pos.x, 16.0, window_size.x - 16.0)
	aim_pos.y = clamp(aim_pos.y, 16.0, window_size.y - 16.0)

	if aim_pos.distance_squared_to(weapons_pos_in_screen) < 10:
		if mov_direction.is_equal_approx(Vector2.ZERO): # El jugador no se esta moviendo
			# Solo actualizamos el mouse cuando previous_position pasa a ser igual que weapons_pos_in_screen
			if not previous_aim_pos.distance_squared_to(weapons_pos_in_screen) < 10:
				get_viewport().warp_mouse(weapons_pos_in_screen + (previous_aim_pos - weapons_pos_in_screen).normalized() * AIM_MIN_DISTANCE)
		else: # El jugador se esta moviendo
			get_viewport().warp_mouse(weapons_pos_in_screen + mov_direction * AIM_MIN_DISTANCE)
	elif (aim_pos - weapons_pos_in_screen).length() < AIM_MIN_DISTANCE:
		get_viewport().warp_mouse(weapons_pos_in_screen + (aim_pos - weapons_pos_in_screen).normalized() * AIM_MIN_DISTANCE)
	else:
		get_viewport().warp_mouse(aim_pos)

	previous_aim_pos = aim_pos

#	return Input.get_vector("ui_aim_left", "ui_aim_right", "ui_aim_up", "ui_aim_down").normalized()


func get_input() -> void:
	mov_direction = Vector2.ZERO
#	if can_move:
	if Input.is_action_pressed("ui_down"):
		mov_direction += Vector2.DOWN
	if Input.is_action_pressed("ui_left"):
		mov_direction += Vector2.LEFT
	if Input.is_action_pressed("ui_right"):
		mov_direction += Vector2.RIGHT
	if Input.is_action_pressed("ui_up"):
		mov_direction += Vector2.UP

	if Input.is_action_just_pressed("ui_armor_ability") and armor.is_able_to_use_ability:
		_use_armor_ability()


func add_coin() -> void:
	SavedData.run_stats.coins += 1


func pick_up_passive_item(item: PassiveItem) -> void:
	if item is PermanentPassiveItem:
		var permanent_passive_item: PermanentPassiveItem = item
		permanent_passive_item.equip(self)
		if not SavedData.run_stats.permanent_passive_items.has(permanent_passive_item):
			SavedData.run_stats.permanent_passive_items.push_back(permanent_passive_item)
		permanent_passive_item_picked_up.emit(permanent_passive_item)
	elif item is WeaponModifier:
		var weapon_modifier_item: WeaponModifier = item
		weapon_modifier_item.equip(weapons.current_weapon)
		weapons.current_weapon.add_weapon_modifier(weapon_modifier_item)
	else: # TemporalPassiveItem
		var temporal_passive_item: TemporalPassiveItem = item
		temporal_passive_item.equip(self)
		if not SavedData.run_stats.temporal_passive_items.has(temporal_passive_item):
			SavedData.run_stats.temporal_passive_items.push_back(temporal_passive_item)
		temporal_passive_item_picked_up.emit(temporal_passive_item)


func unequip_passive_item(item: PassiveItem) -> void:
	assert(item is TemporalPassiveItem)
	var temporal_passive_item: TemporalPassiveItem = item
	temporal_passive_item.unequip(self)
	temporal_passive_item_unequiped.emit(temporal_passive_item)
	SavedData.run_stats.temporal_passive_items.erase(temporal_passive_item)


func switch_camera() -> void:
	var main_scene_camera: Camera2D = get_parent().get_node("Camera2D")
	main_scene_camera.position = position
	main_scene_camera.current = true
	get_node("Camera2D").current = false


func set_armor(new_armor: Armor) -> void:
	assert(new_armor != null)

	if new_armor == armor:
		return

	if not armor_effect_timer.is_stopped():
		armor_effect_timer.stop()
		armor.disable_ability_effect(self)
	elif not armor_recharge_timer.is_stopped():
		armor_recharge_timer.stop()
		armor.disable_ability_effect(self)
	armor.unequip(self)

	armor = new_armor
	#if not armor is NoArmor:
	equip_armor_sound.play()
	armor.equip(self)
	SavedData.run_stats.armor = armor
	sprite.texture = armor.sprite_sheet

	armor_changed.emit(armor)


func jump() -> void:
	jump_animation_player.play("jump")


func add_rotating_item(node: Node2D) -> void:
	add_child(node)
	rotating_items.push_back(node)

	var rot: float = 2*PI / rotating_items.size()
	for i: int in rotating_items.size():
		rotating_items[i].rotation = rot * i


func remove_rotating_item(node: Node2D) -> void:
	rotating_items.erase(node)
	node.queue_free()

	var rot: float = 2*PI / rotating_items.size()
	for i: int in rotating_items.size():
		rotating_items[i].rotation = rot * i


func can_pick_up_weapons() -> bool:
	return weapons.can_pick_up_weapons()


func enable_mirage() -> void:
	(mirage.material as ShaderMaterial).shader = load("res://shaders_and_particles/Mirage.gdshader")
	mirage.show()

	mirage_timer.start()


func disable_mirage() -> void:
	mirage.hide()
	(mirage.material as ShaderMaterial).shader = null


func _use_armor_ability() -> void:
	assert(armor)

	armor.enable_ability_effect(self)

	armor.is_able_to_use_ability = false

	if armor.effect_duration > 0:
		armor_effect_timer.start(armor.effect_duration)
		await armor_effect_timer.timeout
	armor.ability_effect_ended.emit()

	armor_recharge_timer.start(get_armor_recharge_time())
	await armor_recharge_timer.timeout

	armor.is_able_to_use_ability = true

	armor.disable_ability_effect(self)


func get_armor_recharge_time() -> float:
	return armor.recharge_time * (1.0 - armor_ability_recharge_time_reduction)


func set_acid_progress(new_value: float) -> void:
	super(new_value)

	acid_bar.value = acid_progress * 100

	if acid_progress == 0.0:
		acid_bar.hide()


func start_progressing_acid() -> void:
	super()

	acid_bar.show()
