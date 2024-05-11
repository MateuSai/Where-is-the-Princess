extends FiniteStateMachine

enum {
	CHASE,
	ATTACK,
	DEAD,
}

@onready var spear_pivot: Node2D = $"../SpearPivot"
@onready var spear_hitbox: Hitbox = $"../SpearPivot/Sprite2D/Hitbox"
@onready var spear_animation_player: AnimationPlayer = $"../SpearPivot/SpearAnimationPlayer"

func start() -> void:
	set_state(CHASE)

func _state_logic(_delta: float) -> void:
	if state == CHASE:
		parent.move_to_target()
		#parent.move()
		parent.point_to_player()
		if parent.mov_direction.y >= 0 and animation_player.current_animation != "walk":
			animation_player.play("walk")
		elif parent.mov_direction.y < 0 and animation_player.current_animation != "walk_up":
			animation_player.play("walk_up")

func _get_transition() -> int:
	var dis: float = (parent.player.position - parent.global_position).length()
	match state:
		CHASE:
			if dis <= 24:
				return ATTACK
		ATTACK:
			if not spear_animation_player.is_playing():
				return CHASE
	return - 1

func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		CHASE:
			pass
			#animation_player.play("fly")
		ATTACK:
			(parent as Enemy).mov_direction = Vector2.ZERO
			if parent.mov_direction.y >= 0:
				animation_player.play("idle")
			else:
				animation_player.play("idle_up")
			spear_hitbox.knockback_direction = Vector2.RIGHT.rotated(spear_pivot.rotation)
			spear_animation_player.play("attack")
		DEAD:
			pass
			# parent.spawn_loot()
			#animation_player.play("dead")

#func _exit_state(state_exited: int) -> void:
#	match state_exited:
#		ATTACK:
#			parent.pull_back_weapon()
