class_name BlowpipeTribal extends Enemy

const DART_SCENE: PackedScene = preload("res://Characters/Enemies/BlowpipeTribal/Dart.tscn")

const MAX_DISTANCE_TO_PLAYER: int = 130
const MIN_DISTANCE_TO_PLAYER: int = 70

@export var projectile_speed: int = 150

var can_attack: bool = true

var distance_to_player: float

@onready var attack_timer: Timer = get_node("AttackTimer")
@onready var aim_raycast: RayCast2D = get_node("AimRayCast")
@onready var blowpipe_pivot: Node2D = $BlowpipePivot


func _ready() -> void:
	super()

	attack_timer.timeout.connect(_on_attack_timer_timeout)


func _process(_delta: float) -> void:
	#super(delta)

	var vector_to_player: Vector2 = (player.position - global_position)
	blowpipe_pivot.rotation = vector_to_player.angle()
	if blowpipe_pivot.get_index() == 0 and vector_to_player.y > 0:
		move_child(blowpipe_pivot, get_child_count()-1)
	elif blowpipe_pivot.get_index() == get_child_count()-1 and vector_to_player.y < 0:
		move_child(blowpipe_pivot, 0)


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
				_throw_dart()
				attack_timer.start()
	else:
		mov_direction = Vector2.ZERO


func _get_path_to_move_away_from_player() -> void:
	var dir: Vector2 = (global_position - player.position).normalized()
	navigation_agent.target_position = global_position + dir * 100


func _throw_dart() -> void:
	var projectile: Area2D = DART_SCENE.instantiate()
	projectile.exclude.push_back(self)
	projectile.launch(global_position, (player.position - global_position).normalized(), projectile_speed)
	get_tree().current_scene.add_child(projectile)



func _on_attack_timer_timeout() -> void:
	can_attack = true
