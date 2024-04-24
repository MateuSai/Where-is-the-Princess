class_name WeaponNormalAttack extends ActionLeaf

@onready var enemy_weapons: EnemyWeapons = owner.get_node("EnemyWeapons")

func tick(_actor: Node, _blackboard: Blackboard) -> int:
    if enemy_weapons.is_busy():
        return RUNNING

    enemy_weapons.attack()
    return SUCCESS