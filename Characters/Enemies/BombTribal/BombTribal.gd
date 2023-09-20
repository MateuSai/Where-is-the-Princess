class_name BombTribal extends Enemy

const BOMB_PARABOLA_SCENE: PackedScene = preload("res://Characters/Enemies/BombTribal/BombParabola.tscn")

const MAX_DISTANCE_TO_PLAYER: int = 140
const MIN_DISTANCE_TO_PLAYER: int = 60

@export var projectile_speed: int = 150

var can_attack: bool = true

var distance_to_player: float

@onready var attack_timer: Timer = get_node("AttackTimer")
@onready var aim_raycast: RayCast2D = get_node("AimRayCast")


func _ready() -> void:
	super()

	attack_timer.timeout.connect(_on_attack_timer_timeout)


func _on_PathTimer_timeout() -> void:
	if is_instance_valid(player):
		distance_to_player = (player.position - global_position).length()
		if distance_to_player > MAX_DISTANCE_TO_PLAYER:
			_get_path_to_player()
		elif distance_to_player < MIN_DISTANCE_TO_PLAYER:
			_get_path_to_move_away_from_player()
		else:
			aim_raycast.target_position = player.position - global_position
			if can_attack and state_machine.state == state_machine.states.idle and not aim_raycast.is_colliding():
				can_attack = false
				_throw_bomb()
				attack_timer.start()
	else:
		mov_direction = Vector2.ZERO


func _get_path_to_move_away_from_player() -> void:
	var dir: Vector2 = (global_position - player.position).normalized()
	navigation_agent.target_position = global_position + dir * 100


func _throw_bomb() -> void:
	var bomb_parabola: BombParabola = BOMB_PARABOLA_SCENE.instantiate()
	#projectile.exclude.push_back(self)
	#projectile.launch(global_position, (player.position - global_position).normalized(), projectile_speed)
	get_tree().current_scene.add_child(bomb_parabola)
	bomb_parabola.position = global_position
	bomb_parabola.start((player.position - global_position).normalized(), (player.position - global_position).length())



func _on_attack_timer_timeout() -> void:
	can_attack = true
