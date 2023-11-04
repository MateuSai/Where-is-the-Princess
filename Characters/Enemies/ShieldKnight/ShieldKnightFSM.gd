extends FiniteStateMachine


func _init() -> void:
	_add_state("idle")
	_add_state("move")
	_add_state("dead")


func _ready() -> void:
	set_state(states.move)


func _state_logic(_delta: float) -> void:
	match state:
		states.idle:
			parent.move_shield_to_player()
		states.move:
			parent.move_shield_to_player()
			parent.move_to_target()
			parent.move()


func _get_transition() -> int:
#	var distance_to_enemy_to_protect: float
#	if parent.enemy_to_protect:
#		distance_to_enemy_to_protect = (parent.enemy_to_protect.position - parent.position).length()
#	else:
#		distance_to_enemy_to_protect = parent.MIN_DESIRED_DISTANCE_TO_ENEMY_TO_PROTECT
	match state:
		states.idle:
#			if distance_to_enemy_to_protect > parent.MAX_DESIRED_DISTANCE_TO_ENEMY_TO_PROTECT or distance_to_enemy_to_protect < parent.MIN_DESIRED_DISTANCE_TO_ENEMY_TO_PROTECT:
			if not parent.navigation_agent.is_target_reached():
				return states.move
		states.move:
#			if distance_to_enemy_to_protect < parent.MAX_DESIRED_DISTANCE_TO_ENEMY_TO_PROTECT and distance_to_enemy_to_protect > parent.MIN_DESIRED_DISTANCE_TO_ENEMY_TO_PROTECT:
			if parent.navigation_agent.is_target_reached():
				return states.idle
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			animation_player.play("idle")
		states.move:
			animation_player.play("move")
		states.dead:
			pass
			# parent.spawn_loot()
			#animation_player.play("dead")
