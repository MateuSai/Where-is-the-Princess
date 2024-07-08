class_name Bird extends Projectile

const HEIGHT: int = 16

@onready var screen_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@warning_ignore("shadowed_variable")
func _init() -> void:
	collision_layer = 8
	collision_mask = 2 + 4 + 128

	var sprite: Sprite2D = Sprite2D.new()
	sprite.name = "Sprite2D"
	sprite.position.y = -HEIGHT
	sprite.texture = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/enemies/bird/bird_anim_2_spritesheet.png")
	sprite.hframes = 4
	sprite.vframes = 2
	add_child(sprite)

	var col: CollisionShape2D = CollisionShape2D.new()
	col.name = "CollisionShape2D"
	col.position.y = -HEIGHT
	var shape: CircleShape2D = CircleShape2D.new()
	shape.radius = 6
	col.shape = shape
	add_child(col)

	var animation_player: AnimationPlayer = AnimationPlayer.new()
	animation_player.name = "AnimationPlayer"
	animation_player.add_animation_library("bird_animation_library", load("res://Weapons/projectiles/bird_animation_library.tres") as AnimationLibrary)
	add_child(animation_player)

	var screen_notifier: VisibleOnScreenNotifier2D = VisibleOnScreenNotifier2D.new()
	screen_notifier.name = "VisibleOnScreenNotifier2D"
	screen_notifier.position.y = -HEIGHT
	screen_notifier.rect = Rect2( - 16, -16, 32, 32)
	add_child(screen_notifier)

	var life_component: LifeComponent = LifeComponent.new()
	life_component.name = "LifeComponent"
	life_component.max_hp = 1
	life_component.hp = 1
	add_child(life_component)

func _ready() -> void:
	super()
	screen_notifier.screen_exited.connect(queue_free)

	$LifeComponent.damage_taken.connect(func(_dam: int, dir: Vector2, force: int) -> void:
		animation_player.stop()
		direction=dir
		knockback_direction=direction
		speed=force
		set_collision_mask_value(3, true)
		await get_tree().create_timer(0.2).timeout
		destroy()
	)

@warning_ignore("shadowed_variable")
func launch(initial_position: Vector2, dir: Vector2, speed: int, rotate_to_dir: bool=false) -> void:
	super(initial_position, dir, speed, rotate_to_dir)

	if dir.y < 0:
		animation_player.play("bird_animation_library/fly_up")
	else:
		animation_player.play("bird_animation_library/fly")

	if dir.x < 0:
		sprite.flip_h = true

func _collide(body: Node2D, dam: int=damage) -> void:
	if body is BodenTheDruid:
		body.interrupt_lightning_attack()

	super(body, dam)

func destroy() -> void:
	var explosion: AnimatedSprite2D = load("res://Characters/Enemies/SpawnExplosion.tscn").instantiate()
	explosion.position = sprite.global_position
	get_tree().current_scene.add_child(explosion)

	super()
