class_name NakedMark extends Enemy

@onready var spear_pivot: Node2D = $SpearPivot


func point_to_player() -> void:
	var vector_to_target: Vector2 = (player.position - global_position)
	spear_pivot.rotation = vector_to_target.angle()
#	if vector_to_target.x > 0:
#		spear_pivot.scale.x = 1
#	else:
#		spear_pivot.scale.x = -1

	if vector_to_target.x < 0:
		spear_pivot.scale.y = -1
	else:
		spear_pivot.scale.y = 1

	#weapon.rotation = (player.position - global_position).angle()
