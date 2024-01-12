class_name PoisonBombHitbox extends BombHitbox


func _collide(node: Node2D, dam: int = damage) -> void:
	if node is Player:
		(node as Player).enable_mirage()

	super(node, dam)
