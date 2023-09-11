extends Projectile


func _ready() -> void:
	super()

	$Sprite2D.frame_coords.y = randi() % 2


func destroy() -> void:
	$CollisionShape2D.queue_free()
	direction = Vector2.ZERO
	if $AnimationPlayer.current_animation_position < 0.6:
		$AnimationPlayer.seek(0.6)
