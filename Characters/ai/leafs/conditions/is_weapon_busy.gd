class_name IsWeaponBusy extends ConditionLeaf

@onready var enemy_weapons: EnemyWeapons = owner.get_node("EnemyWeapons")

func tick(_actor: Node, _blackboard: Blackboard) -> int:
    if enemy_weapons.is_busy():
        return FAILURE
    else:
        return SUCCESS