extends FiniteStateMachine

@onready var sprite: Sprite2D = $"../Sprite2D"


func _init() -> void:
	_add_state("idle")
	_add_state("move")
	_add_state("dead")


func _ready() -> void:
	set_state(states.move)


func _state_logic(_delta: float) -> void:
	match state:
		states.idle:
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "idle":
				animation_player.play("idle")
			elif dir_to_player.y < 0 and animation_player.current_animation != "idle_up":
				animation_player.play("idle_up")
			if dir_to_player.x > 0 and sprite.flip_h:
				sprite.flip_h = false
			elif dir_to_player.x < 0 and not sprite.flip_h:
				sprite.flip_h = true
		states.move:
			parent.chase()
			parent.move()
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "walk":
				animation_player.play("walk")
			elif dir_to_player.y < 0 and animation_player.current_animation != "walk_up":
				animation_player.play("walk_up")


func _get_transition() -> int:
	match state:
		states.idle:
			if parent.distance_to_player > parent.MAX_DISTANCE_TO_PLAYER or parent.distance_to_player < parent.MIN_DISTANCE_TO_PLAYER:
				return states.move
		states.move:
			if parent.distance_to_player < parent.MAX_DISTANCE_TO_PLAYER and parent.distance_to_player > parent.MIN_DISTANCE_TO_PLAYER:
				return states.idle
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			pass
			#animation_player.play("idle")
		states.move:
			pass
			#animation_player.play("move")
		states.dead:
			pass
			# parent.spawn_loot()
			#animation_player.play("dead")

