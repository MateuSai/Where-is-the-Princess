class_name IsProjectileComingForMe extends ConditionLeaf

@export var closer_than: int = 8

@onready var projectile_detector: ProjectileDetector = owner.get_node("ProjectileDetector")

func tick(_actor: Node, _blackboard: Blackboard) -> int:
    if projectile_detector.are_there_projectiles_inside():
        return SUCCESS
    else:
        return FAILURE