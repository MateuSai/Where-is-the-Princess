class_name WeaponStats extends Resource

@export var weapon_path: String
@export var condition: float = 100: set = set_condition
signal condition_changed(new_condition: int)

signal souls_changed(new_souls, souls_to_activate_ability)
var souls_to_activate_ability: int
@export var souls: int = 0:
	set(new_souls):
		souls = clamp(new_souls, 0, souls_to_activate_ability)
		souls_changed.emit(souls, souls_to_activate_ability)

@export var modifiers: Array[WeaponModifier] = []



@warning_ignore("shadowed_variable")
func _init(weapon_path: String, souls_to_activate_ability: int) -> void:
	self.weapon_path = weapon_path
	self.souls_to_activate_ability = souls_to_activate_ability


func set_condition(new_condition: float) -> void:
	if new_condition == condition:
		return

	condition = clamp(new_condition, 0, 100)
	emit_signal("condition_changed", condition)
