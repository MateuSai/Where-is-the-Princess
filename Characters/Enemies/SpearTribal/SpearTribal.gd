class_name SpearTribal extends Enemy

@onready var spear_pivot: Node2D = $SpearPivot
@onready var spear_hitbox: Hitbox = $SpearPivot/Sprite2D/Hitbox
@onready var aim_ray_cast: RayCast2D = $AimRayCast


func point_to_player() -> void:
	var vector_to_target: Vector2 = (player.position - global_position)
	spear_pivot.rotation = vector_to_target.angle()

	if vector_to_target.x < 0:
		spear_pivot.scale.y = -1
	else:
		spear_pivot.scale.y = 1


func _update_spear_hitbox() -> void:
	spear_hitbox.knockback_direction = Vector2.RIGHT.rotated(spear_pivot.rotation)
