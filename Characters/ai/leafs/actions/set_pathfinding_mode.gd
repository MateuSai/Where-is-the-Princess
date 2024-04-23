class_name SetPathfindingMode extends ActionLeaf

@export var mode: PathfindingComponent.ModeEnum

func tick(actor: Node, _blackboard: Blackboard) -> int:
    match mode:
        PathfindingComponent.ModeEnum.APPROACH:
            (actor.get_node("PathfindingComponent") as PathfindingComponent).mode = PathfindingComponent.Approach.new()
        PathfindingComponent.ModeEnum.FLEE:
            (actor.get_node("PathfindingComponent") as PathfindingComponent).mode = PathfindingComponent.Flee.new()
        PathfindingComponent.ModeEnum.CIRCLE:
            (actor.get_node("PathfindingComponent") as PathfindingComponent).mode = PathfindingComponent.Circle.new()
        PathfindingComponent.ModeEnum.WANDER:
            (actor.get_node("PathfindingComponent") as PathfindingComponent).mode = PathfindingComponent.Wander.new()
        PathfindingComponent.ModeEnum.DODGE:
            (actor.get_node("PathfindingComponent") as PathfindingComponent).mode = PathfindingComponent.Dodge.new()

    return SUCCESS