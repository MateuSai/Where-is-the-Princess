class_name PointWeaponToTarget extends ActionLeaf

@onready var enemy_weapons: EnemyWeapons = owner.get_node("EnemyWeapons")

func tick(actor: Node, _blackboard: Blackboard) -> int:
    enemy_weapons.move(((actor as Enemy).target.global_position - (actor as Enemy).global_position).normalized())

    return SUCCESS