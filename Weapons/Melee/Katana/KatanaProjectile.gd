extends Projectile

var exploded: bool = false


func destroy() -> void:
	if exploded:
		return

	exploded = true
	speed = 0
	$AnimationPlayer.play("explode")
