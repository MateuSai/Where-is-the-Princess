class_name BombTribal extends Enemy

const BOMB_PARABOLA_SCENE: PackedScene = preload ("res://Weapons/projectiles/bombs/BombParabola.tscn")

@export var projectile_speed: int = 150

var can_attack: bool = false

@onready var attack_timer: Timer = get_node("AttackTimer")
@onready var aim_raycast: RayCast2D = get_node("AimRayCast")

func _ready() -> void:
	super()

	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.start()

func _throw_bomb() -> void:
	var bomb_parabola: BombParabola = BOMB_PARABOLA_SCENE.instantiate()
	#projectile.exclude.push_back(self)
	#projectile.launch(global_position, (player.position - global_position).normalized(), projectile_speed)
	get_tree().current_scene.add_child(bomb_parabola)
	bomb_parabola.position = global_position
	bomb_parabola.start((player.position - global_position).normalized(), (player.position - global_position).length())

func _on_attack_timer_timeout() -> void:
	can_attack = true
