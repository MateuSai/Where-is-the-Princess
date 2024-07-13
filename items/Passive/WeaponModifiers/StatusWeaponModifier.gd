class_name StatusWeaponModifier extends WeaponModifier

const INFLICT_CHANCE: int = 30
const MAX_AMOUNT_OF_STATUS_MODIFIERS_PER_WEAPON: int = 2

@export var amount: int = 1

func _add_status_inflicter(weapon: Weapon, status: StatusComponent.Status) -> void:
	weapon.add_status_inflicter(status, amount)

func can_pick_up(player: Player) -> bool:
	return not player.weapons.current_weapon is Dagger and player.weapons.current_weapon.stats.get_amount_of_modifiers() < MAX_AMOUNT_OF_STATUS_MODIFIERS_PER_WEAPON and player.weapons.current_weapon is MeleeWeapon
