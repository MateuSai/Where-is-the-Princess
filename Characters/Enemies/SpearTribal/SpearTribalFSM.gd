extends FiniteStateMachine

@onready var spear_hitbox_collision_shape: CollisionShape2D = $"../SpearPivot/Sprite2D/Hitbox/CollisionShape2D"
@onready var charge_raycast: RayCast2D = $"../SpearPivot/Sprite2D/ChargeRayCast"
@onready var spear_animation_player: AnimationPlayer = $"../SpearPivot/AnimationPlayer"
@onready var aim_raycast: RayCast2D = $"../AimRayCast"
#@onready var attack_animation_leftover_timer: Timer = $"../AttackAnimationLeftoverTimer"


func _init() -> void:
	_add_state("idle")
	_add_state("move")
	_add_state("attack")
	_add_state("charge")
	_add_state("dead")


func _ready() -> void:
	set_state(states.idle)


func _state_logic(_delta: float) -> void:
	match state:
		states.move:
			parent.point_to_player()
			parent.move_to_target()
			parent.move()
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")
		states.attack:
			parent.point_to_player()
		states.charge:
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
			if not spear_animation_player.is_playing():
				if parent.distance_to_player > parent.MAX_DISTANCE_TO_PLAYER or parent.distance_to_player < parent.MIN_DISTANCE_TO_PLAYER:
					return states.move
				else:
					return states.attack
		states.move:
			if not aim_raycast.is_colliding() and parent.distance_to_player > parent.MIN_DISTANCE_TO_CHARGE:
				return states.charge
			elif parent.distance_to_player < parent.MAX_DISTANCE_TO_PLAYER and parent.distance_to_player > parent.MIN_DISTANCE_TO_PLAYER:
				if not spear_animation_player.is_playing():
					return states.attack
				else:
					return states.idle
		states.attack:
			if parent.distance_to_player > parent.MAX_DISTANCE_TO_PLAYER or parent.distance_to_player < parent.MIN_DISTANCE_TO_PLAYER:
				return states.move
		states.charge:
			if not spear_animation_player.is_playing() or charge_raycast.is_colliding():
				return states.idle
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.idle:
			if parent.mov_direction.y >= 0:
				animation_player.play("idle")
			else:
				animation_player.play("idle_up")
			#animation_player.play("fly")
		states.attack:
			if parent.mov_direction.y >= 0:
				animation_player.play("idle")
			else:
				animation_player.play("idle_up")
			spear_animation_player.play("attack")
		states.charge:
			parent.max_speed = 500
			parent.acceleration = 20
			parent.mov_direction = (parent.player.position - parent.global_position).normalized()
			spear_animation_player.play("charge")
		states.dead:
			pass
			# parent.spawn_loot()
			#animation_player.play("dead")


func _exit_state(state_exited: int) -> void:
	match state_exited:
		states.attack:
			spear_animation_player.play("restore")
		states.charge:
			parent.max_speed = 70
			parent.acceleration = 10
			spear_hitbox_collision_shape.disabled = true
			spear_animation_player.stop()
