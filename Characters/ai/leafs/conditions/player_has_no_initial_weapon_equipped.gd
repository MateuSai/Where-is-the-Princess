class_name PlayerHasNoInitialWeaponEquipped extends ConditionLeaf

func tick(_actor: Node, _blackboard: Blackboard) -> int:
	if Globals.player.weapons.current_weapon.get_index() != 0:
		return SUCCESS
	else:
		return FAILURE
