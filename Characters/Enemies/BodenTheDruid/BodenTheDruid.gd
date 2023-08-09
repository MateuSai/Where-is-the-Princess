class_name BodenTheDruid extends Enemy

const MAX_DISTANCE_TO_PLAYER: int = 90
const MIN_DISTANCE_TO_PLAYER: int = 45


var distance_to_player: float

@onready var staff_pivot: Node2D = $StaffPivot
@onready var staff: Sprite2D = $StaffPivot/Staff
@onready var attack_timer: Timer = $AttackTimer


func _ready() -> void:
	super()
	attack_timer.timeout.connect(func():
		_lightning_attack()
	)


func _process(_delta: float) -> void:
	var vector_to_player: Vector2 = player.position - global_position
	staff_pivot.rotation = lerp_angle(staff_pivot.rotation, vector_to_player.angle(), 0.05)
	if Vector2.RIGHT.rotated(staff_pivot.rotation).x > 0:
		staff.scale.y = 1
	else:
		staff.scale.y = -1


func _on_PathTimer_timeout() -> void:
	if is_instance_valid(player):
		distance_to_player = (player.position - global_position).length()
		if distance_to_player > MAX_DISTANCE_TO_PLAYER:
			_get_path_to_player()
		elif distance_to_player < MIN_DISTANCE_TO_PLAYER:
			_get_path_to_move_away_from_player()
		else:
			pass
#			aim_raycast.target_position = player.position - global_position
#			if can_attack and state_machine.state == state_machine.states.idle and not aim_raycast.is_colliding():
#				can_attack = false
#				_throw_knife()
#				attack_timer.start()
	else:
		mov_direction = Vector2.ZERO


func _get_path_to_move_away_from_player() -> void:
	var dir: Vector2 = (global_position - player.position).normalized()
	navigation_agent.target_position = global_position + dir * 100


func _lightning_attack() -> void:
	var lightning_line: LightningLine2D = LightningLine2D.new()
	get_tree().current_scene.add_child(lightning_line)
	lightning_line.lightning(player.position, global_position)
