class_name WeaponReload extends ActionLeaf

@onready var enemy_weapons: EnemyWeapons = owner.get_node("EnemyWeapons")

func tick(_actor: Node, _blackboard: Blackboard) -> int:
	if enemy_weapons.is_busy() or enemy_weapons.current_weapon.weapon_sprite.frame != Crossbow.RELEASED_FRAME:
		return FAILURE

	enemy_weapons.reload()

	return SUCCESS
