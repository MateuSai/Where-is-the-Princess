class_name Bird extends Projectile

@onready var sprite: Sprite2D = $Sprite2D
@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super()
	screen_notifier.screen_exited.connect(queue_free)

	$LifeComponent.damage_taken.connect(func(_dam: int, dir: Vector2, force: int):
		animation_player.stop()
		direction = dir
		speed = force
		set_collision_mask_value(3, true)
		await get_tree().create_timer(0.2).timeout
		destroy()
	)


@warning_ignore("shadowed_variable")
func launch(initial_position: Vector2, dir: Vector2, speed: int) -> void:
	super(initial_position, dir, speed)

	if dir.y < 0:
		animation_player.play("fly_up")
	else:
		animation_player.play("fly")

	if dir.x < 0:
		sprite.flip_h = true


func destroy() -> void:
	var explosion: AnimatedSprite2D = load("res://Characters/Enemies/SpawnExplosion.tscn").instantiate()
	explosion.position = global_position
	get_tree().current_scene.add_child(explosion)

	super()
