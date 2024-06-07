class_name RemoveCollisionsOnDied extends Node

@onready var life_component: LifeComponent = get_node("../LifeComponent")
var room: DungeonRoom

func _ready() -> void:
	var current_parent: Node = get_parent()
	var max_iter: int = 8
	var i: int = 0
	while room == null:
		if current_parent is Control:
			return
		if current_parent is DungeonRoom:
			room = current_parent
			break

		current_parent = current_parent.get_parent()
		i += 1
		if i >= max_iter:
			push_error("Could not find room parent")
			break

	life_component.died.connect(func() -> void:
		$"../CollisionShape2D".free()
		remove_from_group(DungeonRoom.GROUND_UNITS_NAVIGATION_GROUP)
		remove_from_group(DungeonRoom.FLYING_UNITS_NAVIGATION_GROUP)
		room.update_navigation()
	)
