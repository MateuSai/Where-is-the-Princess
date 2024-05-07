class_name Goblin extends Enemy

const THROWABLE_KNIFE_SCENE: PackedScene = preload ("res://Characters/Enemies/Goblin/ThrowableKnife.tscn")

const MAX_DISTANCE_TO_PLAYER: int = 80
const MIN_DISTANCE_TO_PLAYER: int = 40

@export var projectile_speed: int = 150

var can_attack: bool = false

@onready var attack_timer: Timer = get_node("AttackTimer")
@onready var aim_raycast: RayCast2D = get_node("AimRayCast")

func _ready() -> void:
	super()

	attack_timer.timeout.connect(_on_AttackTimer_timeout)
	attack_timer.start()

func _throw_knife() -> void:
	var projectile: Area2D = THROWABLE_KNIFE_SCENE.instantiate()
	projectile.exclude = get_exclude_bodies()
	get_tree().current_scene.add_child(projectile)
	projectile.launch(global_position, (player.position - global_position).normalized(), projectile_speed, true)

func _on_AttackTimer_timeout() -> void:
	can_attack = true
