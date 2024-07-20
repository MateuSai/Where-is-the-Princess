class_name Player extends Character

#signal weapon_switched(prev_index: int, new_index: int)
#signal weapon_picked_up(weapon: Weapon)
#signal weapon_droped(index: int)
#signal weapon_condition_changed(weapon: Weapon, new_value: float)
#signal weapon_status_inflicter_added(weapon: Weapon, status: StatusComponent.Status)

const DIALOGUE_BOX_SCENE: PackedScene = preload ("res://ui/dialogue_system/dialogue_box.tscn")
var dialogue_box: DialogueBox
var dialogue_tween: Tween = null

#const DASH_IMPULSE: int = 22000000
var dash_stamina_cost: float = 30
signal dashed(dash_time: float)

var stamina_regeneration_per_second: float = 25
var stamina_regen_cooldown: float = 0.6
var _stamina_exhausted_tween: Tween = null
var _sweat_drop_tween: Tween = null
signal max_stamina_changed(new_value: float)
var max_stamina: float = 100:
	set(new_value):
		max_stamina = new_value
		max_stamina_changed.emit(max_stamina)
signal oh_shit_im_out_of_stamina()
var _stamina: float = max_stamina:
	set(new_value):
		if new_value < stamina:
			stamina_regen_cooldown_timer.start(stamina_regen_cooldown)
		_stamina = clamp(new_value, 0.0, max_stamina)
		if stamina == 0.0:
			oh_shit_im_out_of_stamina.emit()

		#if stamina < 30 and not _sweat.visible:
		#	_sweat.show()
		#elif stamina >= 30 and _sweat.visible:
		#	_sweat.hide()
var stamina: float:
	get:
		return _stamina
	set(new_value):
		Log.fatal("CANNOT SET STAMINA DIRECTLY! Call consume_stamina instead")

var projectile_speed: float:
	get:
		if weapons.current_weapon is RangedWeapon:
			return (weapons.current_weapon.data as RangedWeaponData).normal_attack_projectile_speed
		else:
			return 5000

signal temporal_passive_item_picked_up(item: TemporalPassiveItem)
signal temporal_passive_item_unequiped(item: TemporalPassiveItem)
signal permanent_passive_item_picked_up(item: PermanentPassiveItem)
signal permanent_passive_item_unequiped(item: PermanentPassiveItem)
signal player_upgrade_item_picked_up(item: PlayerUpgrade)

var armor: Armor = Underpants.new(): set = set_armor
signal armor_changed(new_armor: Armor)
signal armor_ability_used()

var mouse_direction: Vector2
# Controller constants
const AIM_MIN_DISTANCE: int = 45
const AIM_MULTIPLIER: int = 140
var previous_aim_pos: Vector2 = Vector2.ZERO

var extra_water_damage: int = 0
var throw_piercing: int = 1
var extra_fire_damage: int = 0
var attract_souls_even_on_combat: bool = false
var armor_ability_recharge_time_reduction: float = 0.0:
	set(new_value):
		armor_ability_recharge_time_reduction = clamp(new_value, 0.0, 0.95)
signal shop_discount_changed(new_value: float)
var shop_discount: float = 0.0: # # 0 = no discount, 1 = free
	set(new_value):
		shop_discount = new_value
		shop_discount_changed.emit(shop_discount)
var armor_shard_break_probability: float = 0.0:
	set(new_value):
			armor_shard_break_probability = clamp(new_value, 0.0, 100.0)
#var projectiles_homing_degree: float = 0.05

var rotating_items: Array[Node2D] = []

## Room where the player is at this moment. Contains [code]null[/code] if the player is on a corridor
var current_room: DungeonRoom = null:
	set(new_room):
		current_room = new_room
		on_current_room_changed.emit(current_room)
signal on_current_room_changed(new_room: DungeonRoom)

var position_before_jumping: Vector2

enum {
	FREEZING,
	COLD,
	WARM,
}
const COLD_TEMPERATURE: float = 0.0
var temperature_state: int = WARM
var temperature_change_per_second: float = 2.0
var close_temperatures: Array[float] = []
var temperature: float = 20: set = _set_temperature

# @onready var armor_sprite: Sprite2D = get_node("ArmorSprite")

@onready var day_night_system: DayNightSystem = get_tree().current_scene.get_node("DayNightSystem")

@onready var weapons: PlayerWeapons = get_node("Weapons")
@onready var camera: Camera2D = $Camera2D

@onready var jump_animation_player: AnimationPlayer = get_node("JumpAnimationPlayer")

@onready var auto_aim_area: AutoAimArea = $AutoAimArea

@onready var light: PointLight2D = $Light

@onready var armor_effect_timer: Timer = $Timers/ArmorEffectTimer
@onready var armor_recharge_timer: Timer = $Timers/ArmorRechargeTimer
@onready var mirage_timer: Timer = $Timers/MirageTimer
@onready var stamina_regen_cooldown_timer: Timer = $Timers/StaminaRegenCooldownTimer

@onready var ui: MainUi = $UI
@onready var _stamina_icon_red: TextureRect = get_node("%StaminaIconRed")
@onready var mirage: TextureRect = $UI/Mirage

@onready var _sweat: Sprite2D = $Sweat

@onready var equip_armor_sound: AudioStreamPlayer = $EquipArmorSound
@onready var eat_sound: AudioStreamPlayer = $EatSound
@onready var burp_sound: AudioStreamPlayer = $BurpSound

@onready var acid_bar: TextureProgressBar = $AcidBar

func _ready() -> void:
	super()

	disable_mirage()

	acid_bar.hide()
	_sweat.hide()
	_stamina_icon_red.modulate.a = 0.0

	mirage_timer.timeout.connect(disable_mirage)

	weapons.weapon_picked_up.emit(weapons.get_child(0))
	weapons.load_previous_weapons()

	_restore_previous_state()

	#set_armor(NoArmor.new())
	#set_armor(KnightArmor.new())
	if SavedData.run_stats.armor == null:
		set_armor(Underpants.new())
	else:
		set_armor(SavedData.run_stats.armor)
		# To avoid blocking the use of ability when changing scenes if it was recharging
		armor.is_able_to_use_ability = true

	life_component.hp_changed.connect(func(new_hp: int) -> void:
		SavedData.run_stats.hp=new_hp
		if new_hp == 0:
			SavedData.reset_run_stats()
			SavedData.change_biome_by_id_or_path("basecamp")
			SceneTransistor.start_transition_to("res://Game.tscn")
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

	jump_animation_player.animation_finished.connect(func(anim_name: String) -> void:
		if anim_name == "jump":
			if is_on_water():
				var splash: Node2D=load("res://effects/water_splash/water_splash.tscn").instantiate()
				splash.position=global_position
				get_tree().current_scene.add_child(splash)
				var water_damage: int=1 + extra_water_damage
				if water_damage:
					life_component.take_damage(water_damage, Vector2.ZERO, 0, null, null, "water")
				position=position_before_jumping
	)

	if (get_tree().current_scene as Game).day_night_system.is_day():
		light.enabled = false
	else:
		light.enabled = true
	day_night_system.day_started.connect(func() -> void:
		light.enabled=false
	)
	day_night_system.night_started.connect(func() -> void:
		light.enabled=true
	)

	#await get_tree().create_timer(1).timeout
	#StoneHeart.new().pick_up(self)
	#HeartStone.new().pick_up(self)

func _restore_previous_state() -> void:
	for player_upgrade: PlayerUpgrade in SavedData.data.player_upgrades:
		for i: int in player_upgrade.amount:
			player_upgrade.equip(self)

	life_component.hp = SavedData.run_stats.hp
	for permanent_passive_item: PermanentPassiveItem in SavedData.run_stats.get_permanent_passive_items():
		pick_up_passive_item(permanent_passive_item)
	for temporal_passive_item: TemporalPassiveItem in SavedData.run_stats.temporal_passive_items:
		pick_up_passive_item(temporal_passive_item)

func _exit_tree() -> void:
	Globals.player = null

func _process(_delta: float) -> void:
	#camera.position = camera.position.lerp(position, 0.08)

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

func _physics_process(delta: float) -> void:
	super(delta)

	if stamina_regen_cooldown_timer.is_stopped() and _stamina < max_stamina:
		_stamina += stamina_regeneration_per_second * delta

	var target_temperature: float = SavedData.get_biome_conf().temperature if close_temperatures.is_empty() else close_temperatures.max()
	#print_debug(target_temperature)
	var change: float = temperature_change_per_second if (target_temperature - temperature) > 0 else - temperature_change_per_second
	temperature = clamp(temperature + change * delta, -50.0, 50.0)

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
	#mov_direction = Input.get_vector("ui_move_left", "ui_move_right", "ui_move_up", "ui_move_down")
	#if Input.is_action_pressed("ui_move_down"):
		##Input.get_action_strength()
		#mov_direction.y += Vector2.DOWN
	#if Input.is_action_pressed("ui_move_left"):
		#mov_direction += Vector2.LEFT
	#if Input.is_action_pressed("ui_move_right"):
		#mov_direction += Vector2.RIGHT
	#if Input.is_action_pressed("ui_move_up"):
		#mov_direction += Vector2.UP
	if Input.is_action_pressed("ui_move_down"):
		#Input.get_action_strength()
		mov_direction.y += Input.get_action_strength("ui_move_down")
	if Input.is_action_pressed("ui_move_left"):
		mov_direction.x -= Input.get_action_strength("ui_move_left")
	if Input.is_action_pressed("ui_move_right"):
		mov_direction.x += Input.get_action_strength("ui_move_right")
	if Input.is_action_pressed("ui_move_up"):
		mov_direction.y -= Input.get_action_strength("ui_move_up")

	if Input.is_action_just_pressed("ui_dash") and stamina > 0 and not jump_animation_player.is_playing() and dash_timer.is_stopped() and not (mov_direction.is_equal_approx(Vector2.ZERO) and not armor is Underpants):
		_dash_or_jump()

	if Input.is_action_just_pressed("ui_armor_ability") and armor.has_ability() and armor.is_able_to_use_ability:
		_use_armor_ability()

func add_coin(amount: int=1) -> void:
	SavedData.run_stats.coins += amount

func remove_coins(amount: int=1) -> void:
	SavedData.run_stats.coins -= amount

	var coin_destroy_effect: Node2D = load("res://effects/coin_destroy_effect.tscn").instantiate()
	coin_destroy_effect.position = position
	get_tree().current_scene.add_child(coin_destroy_effect)

func pick_up_passive_item(item: PassiveItem) -> void:
	if item is PermanentPassiveItem:
		var permanent_passive_item: PermanentPassiveItem = item
		permanent_passive_item.equip(self)
		if not SavedData.run_stats._permanent_passive_items.has(item): # So the item is not added again when we change maps
			SavedData.run_stats.add_permanent_passive_item(item)

		SavedData.discover_permanent_item_if_not_already((item.get_script() as GDScript).get_path())
		permanent_passive_item_picked_up.emit(permanent_passive_item)
	elif item is WeaponModifier:
		var weapon_modifier_item: WeaponModifier = item
		weapon_modifier_item.equip_to_weapon(weapons.current_weapon)
		weapons.current_weapon.add_weapon_modifier(weapon_modifier_item)
	else: # TemporalPassiveItem
		assert(item is TemporalPassiveItem)
		var temporal_passive_item: TemporalPassiveItem = item
		temporal_passive_item.equip(self)
		if not SavedData.run_stats.temporal_passive_items.has(temporal_passive_item):
			SavedData.run_stats.temporal_passive_items.push_back(temporal_passive_item)

		SavedData.discover_temporal_item_if_not_already((item.get_script() as GDScript).get_path())
		temporal_passive_item_picked_up.emit(temporal_passive_item)

	# Check for unite
	for other_item_path: String in item.get_unite_dictionary().keys():
		for passive_item: PassiveItem in SavedData.run_stats.get_passive_items():
			if other_item_path == passive_item.get_script_path():
				_unite_items(item, passive_item, load(item.get_unite_dictionary()[other_item_path]).new())
				break

func unequip_passive_item(item: PassiveItem) -> void:
	if item is TemporalPassiveItem:
		var temporal_passive_item: TemporalPassiveItem = item
		temporal_passive_item.unequip(self)
		temporal_passive_item_unequiped.emit(temporal_passive_item)
		SavedData.run_stats.temporal_passive_items.erase(temporal_passive_item)
	elif item is PermanentPassiveItem:
		var permanent_passive_item: PermanentPassiveItem = item
		permanent_passive_item.unequip(self)
		permanent_passive_item_unequiped.emit(item)
		SavedData.run_stats.remove_permanent_passive_item(item)
	else:
		assert(false, "Invalid item type")

func _unite_items(item_1: PassiveItem, item_2: PassiveItem, result: PassiveItem) -> void:
	unequip_passive_item(item_1)
	unequip_passive_item(item_2)

	var unite_x: int = 10
	var unite_y: int = -14

	var left_sprite: Sprite2D = Sprite2D.new()
	left_sprite.texture = item_1.get_icon()
	left_sprite.position = Vector2(unite_x * - 1, unite_y)
	left_sprite.scale = Vector2(0.1, 0.1)
	add_child(left_sprite)

	var right_sprite: Sprite2D = Sprite2D.new()
	right_sprite.texture = item_2.get_icon()
	right_sprite.position = Vector2(unite_x, unite_y)
	right_sprite.scale = Vector2(0.1, 0.1)
	add_child(right_sprite)

	var result_sprite: Sprite2D = Sprite2D.new()
	result_sprite.texture = result.get_icon()
	result_sprite.position = Vector2(0, unite_y)
	result_sprite.scale = Vector2(0.1, 0.1)
	result_sprite.hide()
	add_child(result_sprite)

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(left_sprite, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(right_sprite, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain()
	tween.tween_interval(0.2)
	tween.chain()
	tween.tween_property(left_sprite, "position:x", 0, 0.6).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tween.tween_property(right_sprite, "position:x", 0, 0.6).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tween.chain()
	tween.tween_callback(left_sprite.queue_free)
	tween.tween_callback(right_sprite.queue_free)
	tween.tween_callback(result_sprite.show)
	tween.tween_property(result_sprite, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.chain()
	tween.tween_interval(0.3)
	tween.chain()
	tween.tween_property(result_sprite, "position:y", -3, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.chain()
	tween.tween_callback(result_sprite.queue_free)

	result.pick_up(self)

#func switch_camera() -> void:
	#var main_scene_camera: Camera2D = get_parent().get_node("Camera2D")
	#main_scene_camera.position = position
	#main_scene_camera.current = true
	#camera.current = false

func set_armor(new_armor: Armor) -> void:
	assert(new_armor != null)

	if new_armor == armor:
		return

	if not armor_effect_timer.is_stopped():
		armor_effect_timer.stop()
		armor.disable_ability_effect(self)
		ui.stop_armor_ability_flash_effect()
	elif not armor_recharge_timer.is_stopped():
		armor_recharge_timer.stop()
		armor.disable_ability_effect(self)
		ui.stop_armor_ability_flash_effect()
	armor.unequip(self)

	armor = new_armor
	#if not armor is NoArmor:
	equip_armor_sound.play()
	armor.equip(self)
	SavedData.run_stats.armor = armor
	sprite.texture = armor.sprite_sheet

	if not armor is Underpants:
		SavedData.discover_armor_if_not_already((armor.get_script() as GDScript).get_path())

	armor_changed.emit(armor)

func jump() -> void:
	position_before_jumping = position
	jump_animation_player.play("jump")

func _dash_or_jump() -> void:
	consume_stamina(dash_stamina_cost)

	if armor is Underpants:
		dash_cooldown_timer.start()
		jump()
	else:
		_dash(DASH_TIME)

	dashed.emit(DASH_TIME)

func _jump() -> void:
	dash_cooldown_timer.start()
	jump()

func add_rotating_item(node: Node2D) -> void:
	add_child(node)
	rotating_items.push_back(node)

	var rot: float = 2 * PI / rotating_items.size()
	for i: int in rotating_items.size():
		rotating_items[i].rotation = rot * i

	if node is PhysicsBody2D and weapons.current_weapon is MeleeWeapon:
		(weapons.current_weapon as MeleeWeapon).hitbox.exclude.push_back(node)

func remove_rotating_item(node: Node2D) -> void:
	rotating_items.erase(node)
	node.queue_free()

	var rot: float = 2 * PI / rotating_items.size()
	for i: int in rotating_items.size():
		rotating_items[i].rotation = rot * i

func can_pick_up_weapon(weapon: Weapon) -> bool:
	return weapons.can_pick_up_weapon(weapon)

func _on_died() -> void:
	Log.debug("Killed by " + life_component.last_damage_dealer_id)
	if life_component.last_damage_dealer_id == "water":
		SavedData.complete_achievement(Achievements.Achievement.drown)
	#elif life_component.last_damage_dealer_id == "crocodile":
	#	SavedData.complete_achievement(Achievements.Achievement.eaten_by_crocodile)
	SavedData.add_player_times_killed(life_component.last_damage_dealer_id)
	SavedData.add_enemy_player_kill((life_component as PlayerLifeComponent).last_damage_dealer_id)

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
	armor_ability_used.emit()

	armor.is_able_to_use_ability = false

	if armor.effect_duration > 0:
		ui.start_armor_ability_flash_effect()
		armor_effect_timer.start(armor.effect_duration)
		await armor_effect_timer.timeout
		armor.disable_ability_effect(self)
		ui.stop_armor_ability_flash_effect()
	armor.ability_effect_ended.emit()

	armor_recharge_timer.start(get_armor_recharge_time())
	await armor_recharge_timer.timeout

	armor.is_able_to_use_ability = true

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

func is_on_water() -> bool:
	if current_room:
		return current_room.is_on_water(position - current_room.position)
	else:
		return false

func get_exclude_bodies() -> Array[Node2D]:
	var arr: Array[Node2D] = [self]

	for item: Node2D in rotating_items:
		if item is PhysicsBody2D:
			var body: PhysicsBody2D = item
			arr.push_back(body)

	return arr

## @deprecated
func start_dialogue(text: String) -> void:
	dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
	dialogue_box.position = Vector2(5, -26)
	add_child(dialogue_box)

	#var available_dialogue_texts: PackedStringArray = dialogue_texts.duplicate()
	#for i: int in range(available_dialogue_texts.size()-1, -1, -1):
		#if used_dialogue_texts.has(available_dialogue_texts[i]):
			#available_dialogue_texts.remove_at(i)
	#if available_dialogue_texts.is_empty():
		#available_dialogue_texts = dialogue_texts.duplicate()
		#used_dialogue_texts = []
	var random_dialogue_text: String = text
	dialogue_box.start_displaying_text(random_dialogue_text)
	#used_dialogue_texts.push_back(random_dialogue_text)

	dialogue_box.finished_displaying_text.connect(func() -> void:
		dialogue_tween=create_tween()
		dialogue_tween.tween_property(dialogue_box, "modulate:a", 0.0, 1).set_delay(3)
		await dialogue_tween.finished
		dialogue_tween=null
		dialogue_box.queue_free()
		dialogue_box=null
		#dialogue_finished.emit()
	)

func start_dialogues(dialogues: Array[String]) -> void:
	dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
	dialogue_box.position = Vector2(5, -26)
	add_child(dialogue_box)

	while not dialogues.is_empty():
		var dialogue_text: String = dialogues.pop_front()
		dialogue_box.start_displaying_text(dialogue_text)

		await dialogue_box.finished_displaying_text
		await get_tree().create_timer(2.5, false).timeout

	dialogue_tween = create_tween()
	dialogue_tween.tween_property(dialogue_box, "modulate:a", 0.0, 1).set_delay(3)
	await dialogue_tween.finished
	dialogue_tween = null
	dialogue_box.queue_free()
	dialogue_box = null
	#dialogue_finished.emit()

func _set_temperature(new_value: float) -> void:
	temperature = new_value
	match temperature_state:
		COLD:
			if temperature > COLD_TEMPERATURE:
				_set_temperature_state(WARM)
				data.max_speed += 50
		WARM:
			if temperature <= COLD_TEMPERATURE:
				_set_temperature_state(COLD)
				data.max_speed -= 50
				#var ice_status: IceStatusComponent = IceStatusComponent.new( - 1)
				#add_child(ice_status)
				#ice_status.add()

func _set_temperature_state(new_value: int) -> void:
	assert(temperature_state != new_value)
	temperature_state = new_value
	match temperature_state:
		COLD:
			sprite.modulate = Color("88ccef")
		WARM:
			sprite.modulate = Color.WHITE

## Returns false if can't consume stamina. Otherwise returns true
func consume_stamina(amount: float, extra_cooldown: float=0.0) -> bool:
	Log.debug("consume_stamina: " + str(amount))

	if _stamina > 0:
		var diff: float = _stamina - amount
		_stamina -= amount
		if diff < 0:
			stamina_regen_cooldown_timer.start((stamina_regen_cooldown * 4.0 + abs(diff) * 0.1) + extra_cooldown)
			_start_exhausted_effect()
			stamina_regen_cooldown_timer.timeout.connect(_stop_exhausted_effect, CONNECT_ONE_SHOT)
		else:
			stamina_regen_cooldown_timer.start(stamina_regen_cooldown + extra_cooldown)
		return true
	else:
		return false

func _start_exhausted_effect() -> void:
	_sweat.position.y = -6
	_sweat.modulate.a = 1.0
	_sweat.show()

	_stamina_exhausted_tween = create_tween().set_loops()
	_stamina_exhausted_tween.tween_property(_stamina_icon_red, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	_stamina_exhausted_tween.tween_interval(0.6)
	_stamina_exhausted_tween.tween_property(_stamina_icon_red, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

	_sweat_drop_tween = create_tween().set_loops().set_parallel()
	_sweat_drop_tween.tween_property(_sweat, "position:y", 2, 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_sweat_drop_tween.tween_property(_sweat, "modulate:a", 0, 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_sweat_drop_tween.chain().tween_interval(0.3)
	_sweat_drop_tween.chain().tween_callback(func() -> void:
		_sweat.position.y=- 6
		_sweat.modulate.a=1.0
	)

func _stop_exhausted_effect() -> void:
	_sweat.hide()

	_stamina_icon_red.modulate.a = 0.0

	_stamina_exhausted_tween.kill()
	_stamina_exhausted_tween = null

	_sweat_drop_tween.kill()
	_sweat_drop_tween = null

func _get_tile_type() -> String:
	var global_cell: Vector2i = floor(position / Rooms.TILE_SIZE)

	var tilemap_to_check: TileMap = (get_tree().current_scene as Game).rooms.get_tilemap_with_global_cell(global_cell)

	#if current_room != null:
	#	Log.debug("Player on relative tile: " + str(global_cell - Vector2i(current_room.position / Rooms.TILE_SIZE)))
	#	Log.debug("Tilemap used cells: " + str(current_room.tilemap.get_used_cells(0)))

	#if current_room != null and current_room.tilemap.get_used_cells(0).has(Vector2i(global_cell - Vector2i(current_room.position / Rooms.TILE_SIZE))):
	#	Log.debug("Player on room")
	#	tilemap_to_check = current_room.tilemap
	#	assert(tilemap_to_check)
	#else: # Player is on corridor
	#	Log.debug("Player on corridor")
	#	tilemap_to_check = (get_tree().current_scene as Game).rooms.get_corridor_block_tilemap_with_cell(global_cell)
	#	assert(tilemap_to_check)

	#Log.debug("Tilemap global_position: " + str(tilemap_to_check.global_position))
	#Log.debug("Player on relative tile: " + str(global_cell - Vector2i(tilemap_to_check.global_position / Rooms.TILE_SIZE)))
	if tilemap_to_check == null or tilemap_to_check.get_cell_tile_data(0, global_cell - Vector2i(tilemap_to_check.global_position / Rooms.TILE_SIZE)) == null:
		return "no_cell"

	return tilemap_to_check.get_cell_tile_data(0, global_cell - Vector2i(tilemap_to_check.global_position / Rooms.TILE_SIZE)).get_custom_data_by_layer_id(0)
