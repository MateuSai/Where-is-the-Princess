extends FiniteStateMachine


@onready var spear_pivot: Node2D = $"../SpearPivot"
@onready var spear_hitbox: Hitbox = $"../SpearPivot/Sprite2D/Hitbox"
@onready var spear_animation_player: AnimationPlayer = $"../SpearPivot/SpearAnimationPlayer"


func _init() -> void:
	_add_state("chase")
	_add_state("attack")
	_add_state("dead")


func start() -> void:
	set_state(states.chase)


func _state_logic(_delta: float) -> void:
	if state == states.chase:
		parent.move_to_target()
		parent.move()
		parent.point_to_player()
		if parent.mov_direction.y >= 0 and animation_player.current_animation != "walk":
			animation_player.play("walk")
		elif parent.mov_direction.y < 0 and animation_player.current_animation != "walk_up":
			animation_player.play("walk_up")


func _get_transition() -> int:
	var dis: float = (parent.player.position - parent.global_position).length()
	match state:
		states.chase:
			if dis <= 32:
				return states.attack
		states.attack:
			if not spear_animation_player.is_playing():
				return states.chase
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		states.chase:
			pass
			#animation_player.play("fly")
		states.attack:
			if parent.mov_direction.y >= 0:
				animation_player.play("idle")
			else:
				animation_player.play("idle_up")
			spear_hitbox.knockback_direction = Vector2.RIGHT.rotated(spear_pivot.rotation)
			spear_animation_player.play("attack")
		states.dead:
			pass
			# parent.spawn_loot()
			#animation_player.play("dead")


#func _exit_state(state_exited: int) -> void:
#	match state_exited:
#		states.attack:
#			parent.pull_back_weapon()
