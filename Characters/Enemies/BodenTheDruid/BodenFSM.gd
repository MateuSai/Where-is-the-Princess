extends FiniteStateMachine

var rock_dir: Vector2

@onready var MAX_DISTANCE_FOR_MELEE_ATTACK: float = $"../MeleeHitbox/CollisionShape2D".shape.radius * 2
@onready var sprite: Sprite2D = $"../Sprite2D"
@onready var rock_container: Node2D = $"../RockContainer"
@onready var rock_attack_timer: Timer = $"../RockAttackTimer"


func _init() -> void:
	_add_state("idle")
	_add_state("move")
	_add_state("transform")
	_add_state("bear_run")
	_add_state("bear_melee_attack")
	_add_state("bear_throw_rock")
	_add_state("dead")


func _ready() -> void:
	set_state(states.move)

	rock_attack_timer.timeout.connect(func():
		set_state(states.bear_throw_rock)
	)


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

			parent.move_staff()
		states.move:
			parent.chase()
			parent.move()
			if parent.can_move:
				var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
				if dir_to_player.y >= 0 and animation_player.current_animation != "walk":
					animation_player.play("walk")
				elif dir_to_player.y < 0 and animation_player.current_animation != "walk_up":
					animation_player.play("walk_up")
			elif not animation_player.current_animation.begins_with("idle"):
				var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
				if dir_to_player.y >= 0:
					animation_player.play("idle")
				elif dir_to_player.y < 0:
					animation_player.play("idle_up")

			parent.move_staff()

		states.bear_run:
			parent.chase()
			parent.move()
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "bear_run":
				animation_player.play("bear_run")
			elif dir_to_player.y < 0 and animation_player.current_animation != "bear_run_up":
				animation_player.play("bear_run_up")


func _get_transition() -> int:
	match state:
		states.idle:
			if parent.distance_to_player > parent.MAX_DISTANCE_TO_PLAYER or parent.distance_to_player < parent.MIN_DISTANCE_TO_PLAYER:
				return states.move
		states.move:
			if parent.distance_to_player < parent.MAX_DISTANCE_TO_PLAYER and parent.distance_to_player > parent.MIN_DISTANCE_TO_PLAYER:
				return states.idle
		states.transform:
			if not animation_player.is_playing():
				return states.bear_run
		states.bear_run:
			if parent.distance_to_player <= MAX_DISTANCE_FOR_MELEE_ATTACK:
				return states.bear_melee_attack
		states.bear_melee_attack, states.bear_throw_rock:
			if not animation_player.is_playing():
				if randi() % 2 == 0:
					return states.bear_throw_rock
				else:
					return states.bear_run
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			pass
			#animation_player.play("idle")
		states.move:
			pass
			#animation_player.play("move")
		states.transform:
			parent.life_component.invincible = true
			animation_player.play("transform")
			$"../BirdAttackTimer".stop()
			$"../BirdAttackTimer".queue_free()
			$"../LightningAttackTimer".stop()
			$"../LightningAttackTimer".queue_free()
			$"../StaffPivot".queue_free()
			$"../PathTimer".wait_time = 0.15
			parent.max_speed = 160
			parent.acceleration = 70
			parent.mass = 150
			parent.can_move = true
		states.bear_run:
			rock_attack_timer.start(randf_range(0.8, 2.0))
		states.bear_melee_attack:
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y < 0:
				animation_player.play("melee_attack_up")
			else:
				animation_player.play("melee_attack")
			$"../MeleeHitbox".rotation = dir_to_player.angle()
			$"../MeleeHitbox".knockback_direction = dir_to_player
		states.bear_throw_rock:
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			rock_dir = dir_to_player
			if dir_to_player.y < 0:
				parent.move_child(rock_container, 0)
				animation_player.play("throw_rock_up")
			else:
				parent.move_child(rock_container, parent.get_child_count()-1)
				animation_player.play("throw_rock")
			if dir_to_player.x > 0 and sprite.flip_h:
				sprite.flip_h = false
				rock_container.scale.x = 1
			elif dir_to_player.x < 0 and not sprite.flip_h:
				sprite.flip_h = true
				rock_container.scale.x = -1
		states.dead:
			pass
			# parent.spawn_loot()
			#animation_player.play("dead")


func _exit_state(state_exited: int) -> void:
	match state_exited:
		states.transform:
			parent.life_component.invincible = false
		states.bear_run:
			rock_attack_timer.stop()
