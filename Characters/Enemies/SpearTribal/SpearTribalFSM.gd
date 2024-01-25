extends FiniteStateMachine

enum {
	IDLE,
	MOVE,
	ATTACK,
	CHARGE,
	DEAD,
}

const MAX_DISTANCE_TO_PLAYER: int = 24
const MIN_DISTANCE_TO_PLAYER: int = 8
const MIN_DISTANCE_TO_CHARGE: int = 64

@onready var spear_hitbox_collision_shape: CollisionShape2D = $"../SpearPivot/Sprite2D/Hitbox/CollisionShape2D"
@onready var charge_raycast: RayCast2D = $"../SpearPivot/Sprite2D/ChargeRayCast"
@onready var spear_animation_player: AnimationPlayer = $"../SpearPivot/AnimationPlayer"
@onready var aim_raycast: RayCast2D = $"../AimRayCast"
#@onready var attack_animation_leftover_timer: Timer = $"../AttackAnimationLeftoverTimer"


func start() -> void:
	set_state(IDLE)


func _state_logic(_delta: float) -> void:
	match state:
		MOVE:
			parent.point_to_player()
			parent.move_to_target()
			parent.move()
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")
		ATTACK:
			parent.point_to_player()
		CHARGE:
			parent.move()
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")

#		ATTACK:
#			hitbox.rotation = (parent.player.position - parent.global_position).angle()
#			hitbox.knockback_direction = Vector2.RIGHT.rotated(hitbox.rotation)
#			if parent.mov_direction.y >= 0 and animation_player.current_animation != "attack":
#				animation_player.play("attack")
#			elif parent.mov_direction.y < 0 and animation_player.current_animation != "attack_up":
#				animation_player.play("attack_up")


func _get_transition() -> int:
	var distance_to_player: float = (parent.target.global_position - parent.global_position).length()
	match state:
		IDLE:
			if not spear_animation_player.is_playing():
				if distance_to_player > MAX_DISTANCE_TO_PLAYER or distance_to_player < MIN_DISTANCE_TO_PLAYER:
					return MOVE
				else:
					return ATTACK
		MOVE:
			if not aim_raycast.is_colliding() and distance_to_player > MIN_DISTANCE_TO_CHARGE:
				return CHARGE
			elif distance_to_player < MAX_DISTANCE_TO_PLAYER and distance_to_player > MIN_DISTANCE_TO_PLAYER:
				if not spear_animation_player.is_playing():
					return ATTACK
				else:
					return IDLE
		ATTACK:
			if distance_to_player > MAX_DISTANCE_TO_PLAYER or distance_to_player < MIN_DISTANCE_TO_PLAYER:
				return MOVE
		CHARGE:
			if not spear_animation_player.is_playing() or charge_raycast.is_colliding():
				return IDLE
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		IDLE:
			if parent.mov_direction.y >= 0:
				animation_player.play("idle")
			else:
				animation_player.play("idle_up")
			#animation_player.play("fly")
		ATTACK:
			if parent.mov_direction.y >= 0:
				animation_player.play("idle")
			else:
				animation_player.play("idle_up")
			spear_animation_player.play("attack")
		CHARGE:
			parent.max_speed = 500
			#parent.acceleration = 20
			parent.mov_direction = (parent.player.position - parent.global_position).normalized()
			spear_animation_player.play("charge")
		DEAD:
			pass
			# parent.spawn_loot()
			#animation_player.play("dead")


func _exit_state(state_exited: int) -> void:
	match state_exited:
		ATTACK:
			spear_animation_player.play("restore")
		CHARGE:
			parent.max_speed = 70
			#parent.acceleration = 0.1
			spear_hitbox_collision_shape.disabled = true
			spear_animation_player.stop()
