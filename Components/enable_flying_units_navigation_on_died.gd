class_name EnableFlyingUnitsNavigationOnDead extends Node

var life_component: LifeComponent
var room: DungeonRoom


func _ready() -> void:
	life_component = get_node_or_null("../LifeComponent")
	assert(life_component)
	room = get_parent().owner

	life_component.died.connect(func() -> void:
		# Now the flying units will be able to pass over
		(get_parent() as PhysicsBody2D).collision_layer = 16 # Low object
		remove_from_group(DungeonRoom.FLYING_UNITS_NAVIGATION_GROUP)
		room.update_navigation()
	)

