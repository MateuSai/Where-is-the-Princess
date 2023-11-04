class_name SnakeFSM extends FiniteStateMachine

const MIN_DISTANCE_TO_JUMP: int = 80

var player_inside: bool = false

var player_attacks_when_hugged: int = 0

@onready var collision_shape: CollisionShape2D = $"../CollisionShape2D"
@onready var player_detector: Area2D = $"../PlayerDetector"
@onready var jump_timer: Timer = $"../JumpTimer"
@onready var idle_timer: Timer = $"../IdleTimer"


func _init() -> void:
	_add_state("idle")
	_add_state("move")
	_add_state("prejump")
	_add_state("jump")
	_add_state("hug")
	_add_state("dead")


func _ready() -> void:
	set_state(states.move)

	player_detector.body_entered.connect(func(body: Node2D):
		assert(body is Player)
		player_inside = true
	)
	player_detector.body_exited.connect(func(body: Node2D):
		assert(body is Player)
		player_inside = false
	)

	set_process_unhandled_input(false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_attack"):
		player_attacks_when_hugged += 1
		animation_player.play("shake")


func _state_logic(_delta: float) -> void:
	match state:
		states.idle:
			pass
			#parent.move()
		states.move:
			parent.move_to_target()
			parent.move()
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")
		states.jump:
			parent.move()
		states.hug:
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
		states.idle:
			if idle_timer.is_stopped():
				return states.move
		states.move:
			if dis <= MIN_DISTANCE_TO_JUMP:
				return states.prejump
		states.prejump:
			if not animation_player.is_playing():
				return states.jump
		states.jump:
			if jump_timer.is_stopped():
				return states.move
			elif player_inside:
				return states.hug
		states.hug:
			if player_attacks_when_hugged >= 3:
				return states.idle
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			if parent.mov_direction.y >= 0:
				animation_player.play("idle")
			elif parent.mov_direction.y < 0:
				animation_player.play("idle_up")

			idle_timer.start()
		states.move:
			pass
			#animation_player.play("fly")
		states.prejump:
			parent.mov_direction = (parent.player.position - parent.global_position).normalized()

			if parent.mov_direction.y >= 0:
				animation_player.play("prejump")
			else:
				animation_player.play("prejump_up")
		states.jump:
			parent.flying = true
			parent.max_speed = 150

			if animation_player.current_animation == "prejump":
				animation_player.play("jump")
			else:
				animation_player.play("jump_up")

			jump_timer.start()
		states.hug:
			parent.mov_direction = Vector2.ZERO
			player_attacks_when_hugged = 0
			collision_shape.set_deferred("disabled", true)
			parent.player.weapons.disabled = true
			parent.player.can_move = false
			animation_player.play("hug")
			for child in parent.get_children():
				if child is Node2D:
					child.position.y -= 4
			set_process_unhandled_input(true)
		states.dead:
			pass
			# parent.spawn_loot()
			#animation_player.play("dead")


func _exit_state(state_exited: int) -> void:
	match state_exited:
		states.idle:
			idle_timer.stop()
		states.jump:
			parent.flying = false
			parent.max_speed = 50
			jump_timer.stop()
		states.hug:
			collision_shape.set_deferred("disabled", false)
			parent.player.weapons.disabled = false
			parent.player.can_move = true
			for child in parent.get_children():
				if child is Node2D:
					child.position.y += 4
			set_process_unhandled_input(false)
