class_name WeaponStats extends Resource

@export var weapon_path: String
@export var condition: float = 100


@warning_ignore("shadowed_variable")
func _init(weapon_path: String) -> void:
	self.weapon_path = weapon_path
