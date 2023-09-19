class_name BombHitbox extends Hitbox


func _collide(node: Node2D, dam: int = damage) -> void:
	knockback_direction = (node.global_position - global_position).normalized()

	super(node, dam)
