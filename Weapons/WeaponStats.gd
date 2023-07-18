class_name WeaponStats extends Resource

@export var weapon_path: String
@export var condition: float = 100

@export var modifiers: Array[WeaponModifier] = []

signal condition_changed(new_condition: int)


@warning_ignore("shadowed_variable")
func _init(weapon_path: String) -> void:
	self.weapon_path = weapon_path


func set_condition(new_condition: float) -> void:
	if new_condition == condition:
		return

	condition = clamp(new_condition, 0, 100)
	emit_signal("condition_changed", condition)
