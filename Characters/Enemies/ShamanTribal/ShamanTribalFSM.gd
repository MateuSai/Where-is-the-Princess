extends FiniteStateMachine

@onready var search_tribal_mask_timer: Timer = $"../SearchTribalMaskTimer"
@onready var scepter_animation_player: AnimationPlayer = $"../ScepterPivot/ScepterAnimationPlayer"


func _init() -> void:
	_add_state("idle")
	_add_state("move")
	_add_state("resurrect_ally")
	_add_state("dead")


func _ready() -> void:
	set_state(states.idle)


func _state_logic(_delta: float) -> void:
	match state:
		states.move:
			parent.chase()
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
		states.idle:
			if parent.target_tribal_mask:
				return states.resurrect_ally
		states.resurrect_ally:
			if parent.target_tribal_mask == null:
				return states.idle
#			if not spear_animation_player.is_playing():
#				if parent.distance_to_player > parent.MAX_DISTANCE_TO_PLAYER or parent.distance_to_player < parent.MIN_DISTANCE_TO_PLAYER:
#					return states.move
#				else:
#					return states.attack
#		states.move:
#			if parent.distance_to_player < parent.MAX_DISTANCE_TO_PLAYER and parent.distance_to_player > parent.MIN_DISTANCE_TO_PLAYER:
#				if not spear_animation_player.is_playing():
#					return states.attack
#				else:
#					return states.idle
#		states.attack:
#			if parent.distance_to_player > parent.MAX_DISTANCE_TO_PLAYER or parent.distance_to_player < parent.MIN_DISTANCE_TO_PLAYER:
#				return states.move
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			if parent.mov_direction.y >= 0:
				animation_player.play("idle")
			else:
				animation_player.play("idle_up")

			if search_tribal_mask_timer.is_stopped():
				search_tribal_mask_timer.start()
		states.move:
			if search_tribal_mask_timer.is_stopped():
				search_tribal_mask_timer.start()
#		states.attack:
#			if parent.mov_direction.y >= 0:
#				animation_player.play("idle")
#			else:
#				animation_player.play("idle_up")
#			spear_animation_player.play("attack")
		states.resurrect_ally:
			scepter_animation_player.play("resurrect")

			search_tribal_mask_timer.stop()
		states.dead:
			pass
			# parent.spawn_loot()
			#animation_player.play("dead")


func _exit_state(state_exited: int) -> void:
	match state_exited:
		states.resurrect_ally:
			scepter_animation_player.stop()
#		states.attack:
#			spear_animation_player.play("restore")
