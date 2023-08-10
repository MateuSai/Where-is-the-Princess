class_name Bird extends Projectile

@onready var sprite: Sprite2D = $Sprite2D
@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super()
	screen_notifier.screen_exited.connect(queue_free)


func launch(initial_position: Vector2, dir: Vector2, speed: int) -> void:
	super(initial_position, dir, speed)

	if dir.y < 0:
		animation_player.play("fly_up")
	else:
		animation_player.play("fly")

	if dir.x < 0:
		sprite.flip_h = true
