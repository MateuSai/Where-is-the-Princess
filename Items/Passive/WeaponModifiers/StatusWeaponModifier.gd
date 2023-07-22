class_name StatusWeaponModifier extends WeaponModifier

const INFLICT_CHANCE: int = 30

@export var amount: int = 1


func _add_status_inflicter(weapon: Weapon, status: StatusComponent.Status) -> void:
	weapon.add_status_inflicter(status, amount)
