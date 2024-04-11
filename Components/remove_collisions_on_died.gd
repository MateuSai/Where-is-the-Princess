class_name RemoveCollisionsOnDied extends Node

@onready var life_component: LifeComponent = get_node("../LifeComponent")
@onready var room: DungeonRoom = get_parent().get_parent()

func _ready() -> void:
	life_component.died.connect(func() -> void:
		$"../CollisionShape2D".free()
		remove_from_group(DungeonRoom.GROUND_UNITS_NAVIGATION_GROUP)
		remove_from_group(DungeonRoom.FLYING_UNITS_NAVIGATION_GROUP)
		room.update_navigation()
	)
