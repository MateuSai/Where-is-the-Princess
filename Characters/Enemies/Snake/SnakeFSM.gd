class_name SnakeFSM extends FiniteStateMachine

enum {
	IDLE,
	MOVE,
	PREJUMP,
	JUMP,
	HUG,
	DEAD,
}

const MIN_DISTANCE_TO_JUMP: int = 80

var player_inside: bool = false

var player_attacks_when_hugged: int = 0

@onready var collision_shape: CollisionShape2D = $"../CollisionShape2D"
@onready var player_detector: Area2D = $"../PlayerDetector"
@onready var jump_timer: Timer = $"../JumpTimer"
@onready var idle_timer: Timer = $"../IdleTimer"


func start() -> void:
	set_state(MOVE)

	player_detector.body_entered.connect(func(body: Node2D) -> void:
		if not body is Player:
			return

		player_inside = true
	)
	player_detector.body_exited.connect(func(body: Node2D) -> void:
		if not body is Player:
			return

		player_inside = false
	)

	set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_attack"):
		player_attacks_when_hugged += 1
		animation_player.play("shake")


func _state_logic(_delta: float) -> void:
	match state:
		IDLE:
			pass
			#parent.move()
		MOVE:
			parent.move_to_target()
			#parent.move()
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")
		JUMP:
			pass
			#parent.move()
		HUG:
			parent.global_position = parent.player.position + Vector2.DOWN * 2
#		states.attack:
#			hitbox.rotation = (parent.player.position - parent.global_position).angle()
#			hitbox.knockback_direction = Vector2.RIGHT.rotated(hitbox.rotation)
#			if parent.mov_direction.y >= 0 and animation_player.current_animation != "attack":
#				animation_player.play("attack")
#			elif parent.mov_direction.y < 0 and animation_player.current_animation != "attack_up":
#				animation_player.play("attack_up")


func _get_transition() -> int:
	var dis: float = (parent.player.position - parent.global_position).length()
	match state:
		IDLE:
			if idle_timer.is_stopped():
				if dis > MIN_DISTANCE_TO_JUMP:
					return MOVE
				else:
					if not Snake.there_is_a_snake_hugging_the_player:
						return PREJUMP
		MOVE:
			if dis <= MIN_DISTANCE_TO_JUMP:
				if Snake.there_is_a_snake_hugging_the_player:
					return IDLE
				else:
					return PREJUMP
		PREJUMP:
			if not animation_player.is_playing():
				return JUMP
		JUMP:
			if jump_timer.is_stopped():
				return MOVE
			elif player_inside and not Snake.there_is_a_snake_hugging_the_player:
				return HUG
		HUG:
			if player_attacks_when_hugged >= 3:
				return IDLE
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		IDLE:
			if parent.mov_direction.y >= 0:
				animation_player.play("idle")
			elif parent.mov_direction.y < 0:
				animation_player.play("idle_up")

			idle_timer.start()
		MOVE:
			pass
			#animation_player.play("fly")
		PREJUMP:
			parent.mov_direction = (parent.player.position - parent.global_position).normalized()

			if parent.mov_direction.y >= 0:
				animation_player.play("prejump")
			else:
				animation_player.play("prejump_up")
		JUMP:
			parent.data.flying = true
			parent.data.max_speed = 400

			if animation_player.current_animation == "prejump":
				animation_player.play("jump")
			else:
				animation_player.play("jump_up")

			jump_timer.start()
		HUG:
			Snake.there_is_a_snake_hugging_the_player = true

			parent.mov_direction = Vector2.ZERO
			player_attacks_when_hugged = 0
			collision_shape.set_deferred("disabled", true)
			parent.player.weapons.disabled = true
			parent.player.can_move = false
			animation_player.play("hug")
			for child: Node in parent.get_children():
				if child is Node2D:
					child.position.y -= 4
			set_process_unhandled_input(true)
		DEAD:
			pass
			# parent.spawn_loot()
			#animation_player.play("dead")


func _exit_state(state_exited: int) -> void:
	match state_exited:
		IDLE:
			idle_timer.stop()
		JUMP:
			parent.data.flying = false
			parent.data.max_speed = 160
			jump_timer.stop()
		HUG:
			Snake.there_is_a_snake_hugging_the_player = false

			collision_shape.set_deferred("disabled", false)
			parent.player.weapons.disabled = false
			parent.player.can_move = true
			for child: Node in parent.get_children():
				if child is Node2D:
					child.position.y += 4
			set_process_unhandled_input(false)
