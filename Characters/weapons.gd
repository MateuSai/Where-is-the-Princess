class_name Weapons extends Node2D

var current_weapon: Weapon: set = set_current_weapon

#var reflection_sprite: Sprite2D

var throw_spread: float = 0.0

var damage_modifiers_by_type: Dictionary = {}
var damage_modifiers_by_subtype: Dictionary = {}
var condition_cost_multiplier: float = 1.0
var condition_cost_multipliers_by_type: Dictionary = {}

@onready var character: Character = get_parent()

func _ready() -> void:
	pass
	#var reflection_container: Node2D = Node2D.new()
	#reflection_container.z_index = -3
	#reflection_container.modulate.a = 0.4
	#reflection_container.scale.y = -1
	#reflection_sprite = Sprite2D.new()
	#reflection_container.add_child(reflection_sprite)
	#get_parent().call_deferred("add_child", reflection_container)

func move(direction: Vector2) -> void:
	var prev_current_weap_rot: float = current_weapon.rotation
	current_weapon.move(direction)
	#if (prev_current_weap_rot > 0 and current_weapon.rotation < 0) or (prev_current_weap_rot < 0 and current_weapon.rotation > 0):
	if prev_current_weap_rot < 0 and current_weapon.rotation >= 0:
		get_parent().move_child(self, -1)
	elif prev_current_weap_rot > 0 and current_weapon.rotation <= 0:
		get_parent().move_child(self, 0)

	#reflection_sprite.rotation = current_weapon.weapon_sprite.rotation
	#reflection_sprite.position = current_weapon.weapon_sprite.position
	#reflection_sprite.scale = current_weapon.weapon_sprite.scale

func set_current_weapon(new_weapon: Weapon) -> void:
		if current_weapon != null and current_weapon is MeleeWeapon:
			var a: Array[Node2D] = []
			(current_weapon as MeleeWeapon).hitbox.exclude = a

		current_weapon = new_weapon
		current_weapon.weapons = self
		current_weapon.damage_dealer = character
		current_weapon.damage_dealer_id = character.id
		#reflection_sprite.texture = current_weapon.weapon_sprite.texture
		#reflection_sprite.offset = current_weapon.weapon_sprite.offset

		if current_weapon is MeleeWeapon:
			var a: Array[Node2D] = character.get_exclude_bodies()
			(current_weapon as MeleeWeapon).hitbox.exclude = a

func add_damage_modifier_by_type(type: WeaponData.Type, dam: int) -> void:
	if damage_modifiers_by_type.has(type):
		damage_modifiers_by_type[type] += dam
	else:
		damage_modifiers_by_type[type] = dam

func remove_damage_modifier_by_type(type: WeaponData.Type, dam: int) -> void:
	damage_modifiers_by_type[type] -= dam

func add_damage_modifier_by_subtype(subtype: WeaponData.Subtype, dam: int) -> void:
	if damage_modifiers_by_subtype.has(subtype):
		damage_modifiers_by_subtype[subtype] += dam
	else:
		damage_modifiers_by_subtype[subtype] = dam

func remove_damage_modifier_by_subtype(subtype: WeaponData.Subtype, dam: int) -> void:
	damage_modifiers_by_subtype[subtype] -= dam

func get_extra_damage_by_weapon_type_and_subtype(weapon_data: WeaponData) -> int:
	var extra_damage: int = 0

	if damage_modifiers_by_type.has(weapon_data.type):
		extra_damage += damage_modifiers_by_type[weapon_data.type]
	if damage_modifiers_by_subtype.has(weapon_data.subtype):
		extra_damage += damage_modifiers_by_subtype[weapon_data.subtype]

	return extra_damage

func add_condition_cost_multiplier_by_type(type: WeaponData.Type, multiplier: float) -> void:
	if condition_cost_multipliers_by_type.has(type):
		condition_cost_multipliers_by_type[type] += multiplier
	else:
		condition_cost_multipliers_by_type[type] = 1 + multiplier

func remove_condition_cost_multiplier_by_type(type: WeaponData.Type, multiplier: float) -> void:
	condition_cost_multipliers_by_type[type] -= multiplier

func get_condition_cost_multiplier() -> float:
	return condition_cost_multiplier

func get_condition_cost_multiplier_by_type(weapon_data: WeaponData) -> float:
	if condition_cost_multipliers_by_type.has(weapon_data.type):
		return condition_cost_multipliers_by_type[weapon_data.type]
	else:
		return 1.0
