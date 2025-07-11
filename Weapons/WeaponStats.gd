class_name WeaponStats extends Resource

@export var weapon_path: String
@export var condition: float = 100: set = set_condition
signal condition_changed(new_condition: int)

@export var bad_state: bool = false

signal souls_changed(new_souls: int, souls_to_activate_ability: int)
@export var souls_to_activate_ability: int
@export var souls: int = 0:
	set(new_souls):
		souls = clamp(new_souls, 0, souls_to_activate_ability)
		souls_changed.emit(souls, souls_to_activate_ability)

@export var modifiers: Array[WeaponModifier] = []

func set_condition(new_condition: float) -> void:
	if new_condition == condition:
		return

	condition = clamp(new_condition, 0, 100)
	condition_changed.emit(condition)

func get_amount_of_modifiers() -> int:
	var amount: int = 0

	for modifier: WeaponModifier in modifiers:
		if modifier is StatusWeaponModifier:
			amount += modifier.amount
		else:
			amount += 1

	return amount
