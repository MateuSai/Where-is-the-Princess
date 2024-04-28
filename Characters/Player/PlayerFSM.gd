extends FiniteStateMachine

enum {
	IDLE,
	MOVE,
	#HURT,
	DEAD,
}

enum MoveAnimationState {
	MOVE,
	MOVE_BACKWARDS,
	MOVE_UP,
	MOVE_UP_BACKWARDS,
}
var move_animation_state: MoveAnimationState = MoveAnimationState.MOVE

@onready var player: Player = get_parent()


func start() -> void:
	set_state(IDLE)


func _state_logic(_delta: float) -> void:
	match state:
		IDLE:
			player.get_input()
			#player.move()
			#var mouse_direction: Vector2 = (player.get_global_mouse_position() - player.global_position).normalized()
			if player.mouse_direction.y >= 0:
				animation_player.play("idle")
			else:
				animation_player.play("idle_up")
		MOVE:
			player.get_input()
			#player.move()
			#var mouse_direction: Vector2 = (player.get_global_mouse_position() - player.global_position).normalized()
			if player.mouse_direction.y >= 0:
				#print(player.mouse_direction)
				#print(player.mov_direction)
				if ((player.mouse_direction.x > 0 and player.mov_direction.x < 0) or (player.mouse_direction.x < 0 and player.mov_direction.x > 0)) and (animation_player.current_animation != "move" or move_animation_state != MoveAnimationState.MOVE_BACKWARDS):
					#print("a")
					move_animation_state = MoveAnimationState.MOVE_BACKWARDS
					animation_player.play_backwards("move")
				elif ((player.mouse_direction.x >= 0 and player.mov_direction.x >= 0) or (player.mouse_direction.x <= 0 and player.mov_direction.x <= 0)) and (animation_player.current_animation != "move" or move_animation_state != MoveAnimationState.MOVE):
					#print("b")
					move_animation_state = MoveAnimationState.MOVE
					animation_player.play("move")
			else:
				if ((player.mouse_direction.x > 0 and player.mov_direction.x < 0) or (player.mouse_direction.x < 0 and player.mov_direction.x > 0)) and (animation_player.current_animation != "move_up" or move_animation_state != MoveAnimationState.MOVE_UP_BACKWARDS):
					#print("c")
					move_animation_state = MoveAnimationState.MOVE_UP_BACKWARDS
					animation_player.play_backwards("move_up")
				elif ((player.mouse_direction.x >= 0 and player.mov_direction.x >= 0) or (player.mouse_direction.x <= 0 and player.mov_direction.x <= 0)) and (animation_player.current_animation != "move_up" or move_animation_state != MoveAnimationState.MOVE_UP):
					#print("d")
					move_animation_state = MoveAnimationState.MOVE_UP
					animation_player.play("move_up")
		#animation_tree.set("parameters/" + states.keys()[state] + "/blend_position", (player.get_global_mouse_position() - player.global_position).normalized().y)


func _get_transition() -> int:
	match state:
		IDLE:
			if player.velocity.length() > 10:
				return MOVE
		MOVE:
			if player.velocity.length() < 10:
				return IDLE
		#HURT:
			#if not animation_player.is_playing():
				#return IDLE
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		IDLE:
			pass
			#animation_player.play("idle")
			#animation_tree_state_machine.travel("idle")
		MOVE:
			pass
			#animation_player.play("move")
			#animation_tree_state_machine.travel("move")
		#HURT:
			#animation_player.play("hurt")
			#player.weapons.cancel_attack()
		DEAD:
			animation_player.play("dead")
			player.weapons.cancel_attack()
