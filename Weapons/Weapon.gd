@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/heroes/knight/weapon_sword_1.png")
class_name Weapon extends Node2D

#const ANIMATION_LIBRARIES_FOLDER: String = "res://Weapons/animation_libraries/"

const DB: Dictionary = preload ("res://Weapons/data/data.csv").records

#@export var on_floor: bool = false
@export var bad_state: bool = false

var damage_dealer: Node = null: set = _set_damage_dealer
var damage_dealer_id: String: set = _set_damage_dealer_id

static var attack_animation_speed_modifier: float = 1.0

var data: WeaponData = null
var stats: WeaponStats = null

signal condition_changed(weapon: Weapon, new_condition: float)
signal status_inflicter_added(weapon: Weapon, status: StatusComponent.Status)
signal used_normal_attack()
signal used_active_ability()
signal charge_animation_still_executing()

var tween: Tween = null

var charge_timer: Timer

var weapons: Weapons = null

## The name of the scene file (after removing .tscn)
@onready var weapon_id: String = Weapon.get_id_from_path(scene_file_path)

@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var weapon_sprite: Sprite2D = %WeaponSprite
@onready var charge_particles: GPUParticles2D = weapon_sprite.get_node("ChargeParticles")
@onready var player_detector: Area2D = weapon_sprite.get_node("PlayerDetector")
@onready var player_detector_col: CollisionShape2D = player_detector.get_child(0)
@onready var cool_down_timer: Timer = get_node("CoolDownTimer")

@onready var destroy_sound: AudioStreamPlayer = $DestroyWeaponSound

func _ready() -> void:
	data = get_data(scene_file_path)

	var on_floor: bool = not get_parent() is Weapons

	if on_floor:
		z_index = -1
	else:
		player_detector_col.disabled = true
		player_detector.set_collision_mask_value(1, false)
		player_detector.set_collision_mask_value(2, false)

	if stats == null:
		stats = WeaponStats.new()
		stats.weapon_path = scene_file_path
		stats.souls_to_activate_ability = data.souls_to_activate_ability
		if bad_state:
			data.damage = ceil(data.damage / 2.0)
			data.condition_cost_per_normal_attack *= 5.0
			weapon_sprite.modulate = Color.BURLYWOOD

			stats.bad_state = bad_state
			# Random initial condition. We make sure it's not greater than 35
			stats.set_condition(clamp(data.condition_cost_per_normal_attack * randi_range(2, 5) * randf_range(0.8, 1.2), 0, 35))
	else:
		if stats.bad_state:
			data.damage = ceil(data.damage / 2.0)
			data.condition_cost_per_normal_attack *= 5.0
			weapon_sprite.modulate = Color.BURLYWOOD

	set_process_unhandled_input(false)
	@warning_ignore("unsafe_call_argument")
	add_to_group(WeaponData.Type.keys()[data.type])
	add_to_group(WeaponData.Subtype.keys()[data.subtype])

	stats.condition_changed.connect(_on_condition_changed)

	animation_player.animation_started.connect(_on_animation_started)
	animation_player.animation_finished.connect(_on_animation_finished)

	#if damage_modifiers_by_type.has(data.type):
	#	data.damage += damage_modifiers_by_type[data.type]
	#if damage_modifiers_by_subtype.has(data.subtype):
	#	data.damage += damage_modifiers_by_subtype[data.subtype]

	charge_timer = Timer.new()
	charge_timer.wait_time = 0.05
	charge_timer.timeout.connect(func() -> void:
		charge_animation_still_executing.emit()
	)
	add_child(charge_timer)

func load_modifiers() -> void:
	for modifier: WeaponModifier in stats.modifiers:
		# modifier.equip(get_parent().get_parent())
		modifier.equip_to_weapon(self)

func _unhandled_input(event: InputEvent) -> void:
	#if has_strong_attack():
	#	if event.is_action_pressed("ui_attack") and can_attack():
	#		_charge()
	#	elif event.is_action_released("ui_attack"):
	#		if animation_player.is_playing() and get_current_animation().begins_with("charge"):
	#			_attack()
	#		elif is_charging():
	#			_strong_attack()
	#else:
	if event.is_action_pressed("ui_attack") and can_attack():
		_attack()

	if event.is_action_pressed("ui_weapon_ability") and has_active_ability() and not is_busy() and can_active_ability():
		_active_ability()

func move(mouse_direction: Vector2) -> void:
	#if not animation_player.is_playing() or animation_player.current_animation == "charge":
	rotation = mouse_direction.angle()
#	if scale.y == 1 and mouse_direction.x < 0:
#		scale.y = -1
#	elif scale.y == -1 and mouse_direction.x > 0:
#		scale.y = 1

func _attack() -> void:
	animation_player.play(get_animation_full_name("attack"))
	used_normal_attack.emit()

func _active_ability(animation_name: String="active_ability") -> void:
	stats.souls = 0
	used_active_ability.emit()
	cool_down_timer.start()
	animation_player.play(get_animation_full_name(animation_name))

func _strong_attack() -> void:
	animation_player.play(get_animation_full_name("strong_attack"))

func _charge() -> void:
	animation_player.play(get_animation_full_name("charge"))

func cancel_attack() -> void:
	animation_player.play("RESET")

func is_busy() -> bool:
	return animation_player.is_playing() or charge_particles.emitting

func _on_PlayerDetector_body_entered(body: Node2D) -> void:
	if tween:
		tween.kill()

	if body is Player and (body as Player).can_pick_up_weapon(self):
		(body as Player).weapons.pick_up_weapon(self)
		call_deferred("_pick_up")
	else:
		#if tween:
		#	tween.kill()
		player_detector.set_collision_mask_value(2, true)

func _pick_up() -> void:
	player_detector_col.disabled = true # DO NOT USE SET DEFERRED

	player_detector.set_collision_mask_value(1, false)
	player_detector.set_collision_mask_value(2, false)
	animation_player.play("RESET")
	#match data.type:
	#	WeaponData.Type.DAGGER:
	#		position = Vector2(0, 4)
	#	_:
	position = Vector2.ZERO

	z_index = 0

func interpolate_pos(initial_pos: Vector2, final_pos: Vector2, collision_with_world_and_low_objects: bool=true) -> void:
	player_detector_col.disabled = false # DO NOT USE SET DEFERRED

	player_detector.set_collision_mask_value(2, false)

	if collision_with_world_and_low_objects:
		player_detector.set_collision_mask_value(1, true)
		player_detector.set_collision_mask_value(5, true)
	else:
		player_detector.set_collision_mask_value(1, false)
		player_detector.set_collision_mask_value(5, false)

	position = initial_pos
	tween = create_tween()
	tween.tween_property(self, "position", final_pos, 0.8).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_on_Tween_tween_completed)

func _on_Tween_tween_completed() -> void:
	if _is_on_water():
		var splash: Node2D = load("res://effects/water_splash/water_splash.tscn").instantiate()
		splash.position = weapon_sprite.global_position
		get_tree().current_scene.add_child(splash)
		queue_free()
	else:
		player_detector_col.set_deferred("disabled", false)
		player_detector.set_collision_mask_value(2, true)
		z_index = -1

func _on_condition_changed(new_condition: float) -> void:
	#Log.debug("Contidion of weapon " + weapon_id + " changed to " + str(new_condition))
	if get_parent() is Weapons:
		condition_changed.emit(self, new_condition)
	else:
		if new_condition <= 0:
			call_deferred("destroy")

func destroy() -> void:
	#var sprite_rect: Rect2 = weapon_sprite.get_rect()
	#var points: Array[Vector2] = []
	#var triangles: Array[Array] = []

	#points.push_back(sprite_rect.position)
	#points.push_back(sprite_rect.position + Vector2(sprite_rect.size.x, 0))
	#points.push_back(sprite_rect.position + Vector2(0, sprite_rect.size.y))
	#points.push_back(sprite_rect.end)

	#for i: int in 0:
	#	var p: Vector2 = sprite_rect.position + Vector2(randf_range(2, sprite_rect.size.x - 2), randf_range(2, sprite_rect.size.y - 2))
	#	points.push_back(p)

	#var delaunay: PackedInt32Array = Geometry2D.triangulate_delaunay(points)
	#for i: int in range(0, delaunay.size(), 3):
	#	triangles.append([points[delaunay[i + 2]], points[delaunay[i + 1]], points[delaunay[i]]])

	#for t: Array[Vector2] in triangles:
	#	var fragment: WeaponFragment = load("res://effects/fragments/weapon_fragment.tscn").instantiate()
	#	fragment.position = weapon_sprite.global_position
	#	get_tree().current_scene.add_child(fragment)
	#	fragment.throw(get_parent().get_parent(), Vector2.RIGHT.rotated(rotation), weapon_sprite.texture, t)

	var fragments_folder: DirAccess = DirAccess.open(scene_file_path.get_base_dir().path_join("fragments"))
	if fragments_folder:
		for file: String in fragments_folder.get_files():
			if not file.get_extension() == "png":
				continue

			var fragment_texture: Texture2D = load(fragments_folder.get_current_dir().path_join(file))
			var fragment: WeaponFragment = load("res://effects/fragments/weapon_fragment.tscn").instantiate()
			fragment.position = weapon_sprite.global_position
			get_tree().current_scene.add_child(fragment)
			fragment.throw(get_parent().get_parent(), Vector2.RIGHT.rotated(rotation + randf_range( - 0.8, 0.8)), fragment_texture)
	else:
		Log.warn("Weapon " + data.weapon_name + " does not have fragments. Create a folder called fragments in the same directory as the weapon scene and add the fragments on that folder")

	animation_player.stop(true)

	player_detector.queue_free()

	# Shader culiada, tengo que quitar el offset del sprite para que funcione bien
	#weapon_sprite.position += weapon_sprite.offset
	#weapon_sprite.offset = Vector2.ZERO
	#var particles: GPUParticles2D = (load("res://shaders_and_particles/particles/DestroyParticles.tscn") as PackedScene).instantiate()
	#particles.position = weapon_sprite.global_position
	#get_tree().current_scene.add_child(particles)
	#weapon_sprite.material = ResourceLoader.load("res://shaders_and_particles/PixelExplosionMaterial.tres", "ShaderMaterial", ResourceLoader.CACHE_MODE_IGNORE)
	#weapon_sprite.material.resource_local_to_scene = true
	#weapon_sprite.material.set("shader_parameter/progress", 0)
	destroy_sound.play()
	#await create_tween().tween_property(weapon_sprite.material, "shader_parameter/progress", 1, 10).finished
	#await get_tree().create_timer(1).timeout
	queue_free()

func add_status_inflicter(_status: StatusComponent.Status, _amount: int=1) -> void:
	pass

func add_weapon_modifier(item: WeaponModifier) -> void:
	if item is StatusWeaponModifier:
		for modifier: WeaponModifier in stats.modifiers:
			if modifier is StatusWeaponModifier:
				if (item.get_script() as Script).get_path() == (modifier.get_script() as Script).get_path():
					#assert(modifier is StatusWeaponModifier)
					(modifier as StatusWeaponModifier).amount += 1
					return
	elif item is ArrowModifier:
		# We remove the previous modifier
		for modifier: WeaponModifier in stats.modifiers:
			if modifier is ArrowModifier:
#				modifier.unequip(self) # there is no action to be done when the modifier is unequipped, for the moment
				stats.modifiers.erase(modifier)
				modifier = null
				break

	stats.modifiers.push_back(item)

func can_attack() -> bool:
	return not animation_player.is_playing() and (not get_parent().get_parent() is Player or (get_parent().get_parent() as Player).stamina > 0)

func can_active_ability() -> bool:
	return cool_down_timer.is_stopped() and stats.souls == data.souls_to_activate_ability and (not get_parent().get_parent() is Player or (get_parent().get_parent() as Player).stamina > 0)

func get_texture() -> Texture2D:
	return data.icon

func has_active_ability() -> bool:
	return (animation_player.has_animation("active_ability") or animation_player.has_animation("active_ability_1")) and data.active_ability_icon and not stats.bad_state

func has_strong_attack() -> bool:
	return animation_player.has_animation(data.animation_library.path_join("charge")) or animation_player.has_animation(data.animation_library.path_join("charge_1"))

func can_pick_up_soul() -> bool:
	return has_active_ability() and stats.souls < data.souls_to_activate_ability

func _on_animation_started(anim_name: StringName) -> void:
	if anim_name.contains("charge"):
		charge_timer.start()
	elif not charge_timer.is_stopped():
		charge_timer.stop()

	if anim_name.contains("attack"):
		animation_player.speed_scale = Weapon.attack_animation_speed_modifier
	else:
		animation_player.speed_scale = 1.0

func _on_animation_finished(anim_name: String) -> void:
	if anim_name.begins_with("active_ability"):
		_decrease_weapon_condition(data.active_ability_condition_cost)
#		stats.set_condition(stats.condition - active_ability_condition_cost)

func get_info() -> String:
	@warning_ignore("unsafe_call_argument")
	return tr(data.weapon_name) + "\n\n" + tr(WeaponData.Type.keys()[data.type])

## Get currently playing animation without library name in front
func get_current_animation() -> String:
	var complete_current_animation: PackedStringArray = animation_player.current_animation.split("/")
	return complete_current_animation[complete_current_animation.size() - 1]

## Returns the full animation name, appending the library name at the start if necessary
func get_animation_full_name(anim: String) -> String:
	if animation_player.has_animation(anim):
		return anim
	elif animation_player.has_animation(data.animation_library.path_join(anim)):
		return data.animation_library.path_join(anim)
	else:
		#printerr(str(weapon_id) + " animation player does not have animation " + anim)
		return ""

func set_damage(new_damage: int) -> void:
	data.damage = new_damage

func set_ability_damage(new_ability_damage: int) -> void:
	data.ability_damage = new_ability_damage

func set_knockback(new_knockback: int) -> void:
	data.knockback = new_knockback

func set_ability_knockback(new_ability_knockback: int) -> void:
	data.ability_knockback = new_ability_knockback

func _decrease_weapon_condition(by: float) -> void:
	#Log.debug("Condition before: " + str(stats.condition))
	stats.condition -= (by + 0.5 * stats.modifiers.size()) * (1 - Globals.player.weapon_degradation_reduction) * (weapons.get_condition_cost_multiplier_by_type(data) if weapons else 1.0)
	#Log.debug("Condition after: " + str(stats.condition))

func _set_damage_dealer(new_damage_dealer: Node) -> void:
	damage_dealer = new_damage_dealer

func _set_damage_dealer_id(new_id: String) -> void:
	damage_dealer_id = new_id

func _is_on_water() -> bool:
	if Globals.player.current_room:
		return Globals.player.current_room.tilemap.get_cell_atlas_coords(DungeonRoom.WATER_LAYER_ID, Globals.player.current_room.tilemap.local_to_map(position - Globals.player.current_room.position)) != Vector2i( - 1, -1)
	else:
		return false

func is_charging() -> bool:
	return not charge_timer.is_stopped()

static func get_weapon_path(weap_name: String) -> String:
	var dir: DirAccess = DirAccess.open("res://Weapons/")
	assert(dir)

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			var dir2: DirAccess = DirAccess.open(dir.get_current_dir().path_join(file_name))
			dir2.list_dir_begin()
			var file_name2: String = dir2.get_next()
			while file_name2 != "":
				if file_name2 == weap_name.to_pascal_case() or file_name2 == weap_name.to_snake_case():
					assert(FileAccess.file_exists(dir2.get_current_dir().path_join(file_name2).path_join(file_name2 + ".tscn")))
					return dir2.get_current_dir().path_join(file_name2).path_join(file_name2 + ".tscn")
				file_name2 = dir2.get_next()
		else:
			if file_name == weap_name.to_pascal_case() or file_name == weap_name.to_snake_case():
				assert(FileAccess.file_exists(dir.get_current_dir().path_join(file_name + ".tscn")))
				return dir.get_current_dir().path_join(file_name + ".tscn")
		file_name = dir.get_next()

	return ""

static func get_id_from_path(path: String) -> String:
	return path.get_file().trim_suffix(".tscn").to_snake_case()

static func get_data(path: String) -> WeaponData:
	var id: String = get_id_from_path(path)
	if DB.has(id):
		return WeaponData.from_dic(DB[id])
	else:
		var data_path: String = path.replace(path.get_file(), "data.tres")
		if FileAccess.file_exists(data_path):
			return load(data_path)

	Log.warn("Could not get data for weapon with path " + path + " and id " + id + " db: " + str(DB))
	return null
