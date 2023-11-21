extends FiniteStateMachine

enum {
	IDLE,
	MOVE,
	RESURRECT_ALLY,
	DEAD,
}

@onready var search_tribal_mask_timer: Timer = $"../SearchTribalMaskTimer"
@onready var scepter_animation_player: AnimationPlayer = $"../ScepterPivot/ScepterAnimationPlayer"


func start() -> void:
	set_state(IDLE)


func _state_logic(_delta: float) -> void:
	match state:
		MOVE:
			parent.move_to_target()
			parent.move()
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")
#		states.attack:
#			hitbox.rotation = (parent.player.position - parent.global_position).angle()
#			hitbox.knockback_direction = Vector2.RIGHT.rotated(hitbox.rotation)
#			if parent.mov_direction.y >= 0 and animation_player.current_animation != "attack":
#				animation_player.play("attack")
#			elif parent.mov_direction.y < 0 and animation_player.current_animation != "attack_up":
#				animation_player.play("attack_up")


func _get_transition() -> int:
	match state:
		IDLE:
			if parent.target_tribal_mask:
				return RESURRECT_ALLY
		RESURRECT_ALLY:
			if parent.target_tribal_mask == null:
				return IDLE
#			if not spear_animation_player.is_playing():
#				if parent.distance_to_player > parent.MAX_DISTANCE_TO_PLAYER or parent.distance_to_player < parent.MIN_DISTANCE_TO_PLAYER:
#					return MOVE
#				else:
#					return states.attack
#		MOVE:
#			if parent.distance_to_player < parent.MAX_DISTANCE_TO_PLAYER and parent.distance_to_player > parent.MIN_DISTANCE_TO_PLAYER:
#				if not spear_animation_player.is_playing():
#					return states.attack
#				else:
#					return IDLE
#		states.attack:
#			if parent.distance_to_player > parent.MAX_DISTANCE_TO_PLAYER or parent.distance_to_player < parent.MIN_DISTANCE_TO_PLAYER:
#				return MOVE
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		IDLE:
			if parent.mov_direction.y >= 0:
				animation_player.play("idle")
			else:
				animation_player.play("idle_up")

			if search_tribal_mask_timer.is_stopped():
				search_tribal_mask_timer.start()
		MOVE:
			if search_tribal_mask_timer.is_stopped():
				search_tribal_mask_timer.start()
#		states.attack:
#			if parent.mov_direction.y >= 0:
#				animation_player.play("idle")
#			else:
#				animation_player.play("idle_up")
#			spear_animation_player.play("attack")
		RESURRECT_ALLY:
			scepter_animation_player.play("resurrect")

			search_tribal_mask_timer.stop()
		DEAD:
			pass
			# parent.spawn_loot()
			#animation_player.play("dead")


func _exit_state(state_exited: int) -> void:
	match state_exited:
		RESURRECT_ALLY:
			scepter_animation_player.stop()
#		states.attack:
#			spear_animation_player.play("restore")
