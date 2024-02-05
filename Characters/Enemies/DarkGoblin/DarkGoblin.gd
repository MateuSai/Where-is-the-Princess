class_name DarkGoblin extends Enemy

const THROWABLE_KNIFE_SCENE: PackedScene = preload("res://Characters/Enemies/Goblin/ThrowableKnife.tscn")

const MAX_DISTANCE_TO_PLAYER: int = 140
const MIN_DISTANCE_TO_PLAYER: int = 40

var projectile_speed: int = 200

var distance_to_player: float

@onready var eye_grow_sprite: Sprite2D = get_node("EyeGrowSprite")
@onready var swap_cooldown_timer: Timer = $SwapCooldownTimer
@onready var aim_raycast: RayCast2D = get_node("AimRayCast")


func _ready() -> void:
	super()

	eye_grow_sprite.hide()
	swap_cooldown_timer.timeout.connect(func():
		eye_grow_sprite.show()
	)


func normal_attack() -> void:
	_throw_knife(randf_range(-0.1, 0.1))
	await get_tree().create_timer(randf_range(0.08, 0.15)).timeout
	_throw_knife(randf_range(-0.1, 0.1))


func _throw_knife(angle_offset: float = 0) -> void:
	var projectile: Area2D = THROWABLE_KNIFE_SCENE.instantiate()
	projectile.exclude = get_exclude_bodies()
	get_tree().current_scene.add_child(projectile)
	projectile.launch(global_position, (player.position - global_position).normalized().rotated(angle_offset), projectile_speed, true)


func swap_and_throw_knives() -> void:
	eye_grow_sprite.hide()
	_swap()
	_throw_knife()
	_throw_knife(PI/6)
	_throw_knife(-PI/6)


func _swap() -> void:
	collision_shape.disabled = true
	var player_pos: Vector2 = player.position
	player.position = global_position
	global_position = player_pos
	await get_tree().process_frame
	collision_shape.disabled = false


func _on_change_dir() -> void:
	super()
	eye_grow_sprite.flip_h = !eye_grow_sprite.flip_h
