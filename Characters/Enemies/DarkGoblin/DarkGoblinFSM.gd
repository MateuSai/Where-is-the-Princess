extends FiniteStateMachine

const MIN_ATTACK_COOLDOWN: float = 0.5
const MAX_ATTACK_COOLDOWN: float = 1.0

const MIN_ABILTY_COOLDOWN: float = 2.5
const MAX_ABILITY_COOLDOWN: float = 4


@onready var swap_cooldown_timer: Timer = get_node("../SwapCooldownTimer")
@onready var attack_timer: Timer = get_node("../AttackTimer")


func _init() -> void:
	_add_state("idle")
	_add_state("move")
	_add_state("hurt")
	_add_state("dead")


func _ready() -> void:
	swap_cooldown_timer.start(randf_range(MIN_ABILTY_COOLDOWN, MAX_ABILITY_COOLDOWN))
	attack_timer.start(randf_range(MIN_ATTACK_COOLDOWN, MAX_ATTACK_COOLDOWN))
	attack_timer.timeout.connect(func():
		if swap_cooldown_timer.is_stopped() and (parent.player.position - parent.global_position).length() < parent.MAX_DISTANCE_TO_PLAYER and (parent.player.position - parent.global_position).length() > 16:
			parent.swap_and_throw_knives()
			swap_cooldown_timer.start(randf_range(MIN_ABILTY_COOLDOWN, MAX_ABILITY_COOLDOWN))
		else:
			parent.normal_attack()
		attack_timer.start(randf_range(MIN_ATTACK_COOLDOWN, MAX_ATTACK_COOLDOWN))
	)
	set_state(states.move)


func _state_logic(_delta: float) -> void:
	match state:
		states.idle:
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "idle":
				animation_player.play("idle")
			elif dir_to_player.y < 0 and animation_player.current_animation != "idle_up":
				animation_player.play("idle_up")
		states.move:
			parent.chase()
			parent.move()
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif dir_to_player.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")


func _get_transition() -> int:
	match state:
		states.idle:
			if parent.distance_to_player > parent.MAX_DISTANCE_TO_PLAYER or parent.distance_to_player < parent.MIN_DISTANCE_TO_PLAYER:
				return states.move
		states.move:
			if parent.distance_to_player < parent.MAX_DISTANCE_TO_PLAYER and parent.distance_to_player > parent.MIN_DISTANCE_TO_PLAYER:
				return states.idle
		states.hurt:
			if not animation_player.is_playing():
				return states.move
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			pass
			#animation_player.play("idle")
		states.move:
			pass
			#animation_player.play("move")
		states.hurt:
			animation_player.play("hurt")
		states.dead:
			attack_timer.stop()
			parent.spawn_loot()
			animation_player.play("dead")
