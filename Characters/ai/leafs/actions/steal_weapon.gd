class_name StealWeapon extends ActionLeaf

func tick(actor: Node, _blackboard: Blackboard) -> int:
    (actor as Goose).steal_player_weapon()

    return SUCCESS