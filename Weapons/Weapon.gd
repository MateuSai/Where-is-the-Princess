@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/heroes/knight/weapon_sword_1.png")
class_name Weapon extends Node2D

@export var on_floor: bool = false

enum Type {
	SPEAR,
	SWORD,
	HAMMER,
	DAGGER,
	AXE,

	BOW,
}
@export var type: Type
@export var weapon_name: String = ""
@export var description: String = ""
@export var icon: Texture = null ## 16x16 weapon icon, the one that appears on the bottom of the screen

@export var condition_cost_per_normal_attack: float = 5

@export_group("Active Ability")
@export var active_ability_icon: Texture ## Icon of the weapon's active ability
@export var souls_to_activate_ability: int = 3 ## The souls you need to collect in order to activate the ability
@export_range(0.0, 100.0) var active_ability_condition_cost: float = 10 ## The weapon condition will decrease this amount after using the ability. Remember all the weapons have 100 condition initially
@export var ability_damage: int = 2: set = set_ability_damage
@export_group("")

static var damage_modifiers_by_type: Dictionary = {}
@export var damage: int = 1: set = set_damage

var stats: WeaponStats = null

signal condition_changed(weapon: Weapon, new_condition: float)
signal status_inflicter_added(weapon: Weapon, status: StatusComponent.Status)
signal used_active_ability()

var tween: Tween = null
@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")
@onready var charge_particles: GPUParticles2D = get_node("Node2D/Sprite2D/ChargeParticles")
@onready var weapon_sprite: Sprite2D = get_node("Node2D/Sprite2D")
@onready var player_detector: Area2D = weapon_sprite.get_node("PlayerDetector")
@onready var cool_down_timer: Timer = get_node("CoolDownTimer")

@onready var destroy_sound: AudioStreamPlayer = $DestroyWeaponSound


func _ready() -> void:
	var data: Dictionary = preload("res://Weapons/data/data.csv").records
	if data.has(name):
		var weapon_data: Dictionary = data[name]
		_load_csv_data(weapon_data)

	if not on_floor:
		player_detector.set_collision_mask_value(1, false)
		player_detector.set_collision_mask_value(2, false)

	if stats == null:
		stats = WeaponStats.new(scene_file_path, souls_to_activate_ability)

	set_process_unhandled_input(false)
	add_to_group(Type.keys()[type])

	stats.condition_changed.connect(_on_condition_changed)

	animation_player.animation_started.connect(_on_animation_started)
	animation_player.animation_finished.connect(_on_animation_finished)

	if damage_modifiers_by_type.has(type):
		self.damage = damage + damage_modifiers_by_type[type]
	else:
		self.damage = damage
	self.ability_damage = ability_damage


func load_modifiers() -> void:
	for modifier in stats.modifiers:
		# modifier.equip(get_parent().get_parent())
		modifier.equip(self)


func _load_csv_data(data: Dictionary) -> void:
	weapon_name = data["name"]
	icon = load(data["icon"])
	type = Type.values()[Type.keys().find(data["type"])]
	damage = data.damage
	ability_damage = data.ability_damage
	condition_cost_per_normal_attack = data.condition_cost_per_normal_attack
	if FileAccess.file_exists(data["ability_icon"]):
		active_ability_icon = load(data["ability_icon"])
	else:
		active_ability_icon = null
	souls_to_activate_ability = data["ability_cost"]
	active_ability_condition_cost = data["ability_condition_cost"]


func _unhandled_input(event: InputEvent) -> void:
	if has_strong_attack():
		if event.is_action_pressed("ui_attack") and not animation_player.is_playing():
			_charge()
		elif event.is_action_released("ui_attack"):
			if animation_player.is_playing() and animation_player.current_animation.begins_with("charge"):
				_attack()
			elif charge_particles.emitting:
				_strong_attack()
	else:
		if event.is_action_pressed("ui_attack"):
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
	animation_player.play("attack")


func _active_ability(animation_name: String = "active_ability") -> void:
	stats.souls = 0
	used_active_ability.emit()
	cool_down_timer.start()
	animation_player.play(animation_name)


func _strong_attack() -> void:
	animation_player.play("strong_attack")


func _charge() -> void:
	animation_player.play("charge")


func cancel_attack() -> void:
	animation_player.play("RESET")


func is_busy() -> bool:
	return animation_player.is_playing() or charge_particles.emitting


func _on_PlayerDetector_body_entered(body: Node2D) -> void:
	if body is Player and body.can_pick_up_weapons():
		body.weapons.pick_up_weapon(self)
		_pick_up()
	else:
		if tween:
			tween.kill()
		player_detector.set_collision_mask_value(2, true)


func _pick_up() -> void:
	player_detector.set_collision_mask_value(1, false)
	player_detector.set_collision_mask_value(2, false)
	animation_player.play("RESET")
	position = Vector2.ZERO


func interpolate_pos(initial_pos: Vector2, final_pos: Vector2) -> void:
	position = initial_pos
	tween = create_tween()
	tween.tween_property(self, "position", final_pos, 0.8).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	tween.finished.connect(_on_Tween_tween_completed)
	player_detector.set_collision_mask_value(1, true)


func _on_Tween_tween_completed() -> void:
	player_detector.set_collision_mask_value(2, true)


func _on_condition_changed(new_condition: float) -> void:
	if get_parent() is Weapons:
		emit_signal("condition_changed", self, new_condition)
	else:
		if new_condition <= 0:
			destroy()


func destroy() -> void:
	animation_player.stop(true)

	player_detector.queue_free()

	# Shader culiada, tengo que quitar el offset del sprite para que funcione bien
	weapon_sprite.position += weapon_sprite.offset
	weapon_sprite.offset = Vector2.ZERO
	var particles: GPUParticles2D = load("res://Shaders and Particles/DestroyParticles.tscn").instantiate()
	particles.position = weapon_sprite.global_position
	get_tree().current_scene.add_child(particles)
	weapon_sprite.material = ResourceLoader.load("res://Shaders and Particles/PixelExplosionMaterial.tres", "ShaderMaterial", ResourceLoader.CACHE_MODE_IGNORE)
	#weapon_sprite.material.resource_local_to_scene = true
	#weapon_sprite.material.set("shader_parameter/progress", 0)
	destroy_sound.play()
	await create_tween().tween_property(weapon_sprite.material, "shader_parameter/progress", 1, 10).finished
	#await get_tree().create_timer(1).timeout
	queue_free()


func add_status_inflicter(_status: StatusComponent.Status, _amount: int = 1) -> void:
	pass


func add_weapon_modifier(item: WeaponModifier) -> void:
	if item is StatusWeaponModifier:
		for modifier in stats.modifiers:
			if modifier is StatusWeaponModifier:
				if item.get_script().get_path() == modifier.get_script().get_path():
					#assert(modifier is StatusWeaponModifier)
					modifier.amount += 1
					return
	elif item is ArrowModifier:
		# We remove the previous modifier
		for modifier in stats.modifiers:
			if modifier is ArrowModifier:
#				modifier.unequip(self) # there is no action to be done when the modifier is unequipped, for the moment
				stats.modifiers.erase(modifier)
				modifier = null
				break

	stats.modifiers.push_back(item)


func can_active_ability() -> bool:
	return cool_down_timer.is_stopped() and stats.souls == souls_to_activate_ability


func get_texture() -> Texture2D:
	return icon


func has_active_ability() -> bool:
	return (animation_player.has_animation("active_ability") or animation_player.has_animation("active_ability_1")) and active_ability_icon


func has_strong_attack() -> bool:
	return animation_player.has_animation("charge") or animation_player.has_animation("charge_1")


func can_pick_up_soul() -> bool:
	return has_active_ability() and stats.souls < souls_to_activate_ability


func _on_animation_started(_anim_name: StringName) -> void:
	pass


func _on_animation_finished(anim_name: String) -> void:
	if anim_name.begins_with("active_ability"):
		_decrease_weapon_condition(active_ability_condition_cost)
#		stats.set_condition(stats.condition - active_ability_condition_cost)


func get_info() -> String:
	return tr(weapon_name) + "\n\n" + tr(Type.keys()[type])


@warning_ignore("shadowed_variable")
static func _add_damage_modifier_by_type(type: Type, dam: int) -> void:
	if damage_modifiers_by_type.has(type):
		damage_modifiers_by_type[type] += dam
	else:
		damage_modifiers_by_type[type] = dam


@warning_ignore("shadowed_variable")
static func _remove_damage_modifier_by_type(type: Type, dam: int) -> void:
	damage_modifiers_by_type[type] -= dam


func set_damage(new_damage: int) -> void:
		damage = new_damage


func set_ability_damage(new_ability_damage: int) -> void:
		ability_damage = new_ability_damage


func _decrease_weapon_condition(by: float) -> void:
	stats.condition -= (by + 0.5 * stats.modifiers.size()) * (1 - Globals.player.weapon_degradation_reduction)
