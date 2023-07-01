class_name WeaponHitbox extends Hitbox

signal collided_with_something()


func _on_Hitbox_area_entered(area: Area2D) -> void:
	area.queue_free()


func _collide(body: Node2D) -> void:
	collided_with_something.emit()
	super(body)
