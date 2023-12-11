extends Projectile

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super()

	($Sprite2D as Sprite2D).frame_coords.y = randi() % 2


func destroy() -> void:
	$CollisionShape2D.queue_free()
	direction = Vector2.ZERO
	if animation_player.current_animation_position < 0.6:
		animation_player.seek(0.6)
