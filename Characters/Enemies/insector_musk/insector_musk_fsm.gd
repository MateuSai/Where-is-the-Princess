extends FiniteStateMachine

enum {
	HIDDEN,
	APPROACH,
	MELEE_ATTACK,
	FLEE,
	RANGED_ATTACK,
	DEAD,
}

var max_consecutive_spits: int

@onready var insector_musk: InsectorMusk = get_parent()
@onready var pathfinding_component: PathfindingComponent = $"../PathfindingComponent"
@onready var wings: Sprite2D = $"../Wings"
@onready var hitbox: Hitbox = $"../Hitbox"
@onready var throw_acid_spit_timer: Timer = $"../ThrowAcidSpitTimer"


func start() -> void:
	set_state(HIDDEN)


func _state_logic(_delta: float) -> void:
	match state:
		APPROACH, FLEE:
			parent.move_to_target()
			parent.move()
			if parent.mov_direction.y >= 0 and animation_player.current_animation != "fly":
				animation_player.play("fly")
				parent.move_child(wings, 0)
			elif parent.mov_direction.y < 0 and animation_player.current_animation != "fly_up":
				animation_player.play("fly_up")
				parent.move_child(wings, parent.get_child_count())
		HIDDEN, RANGED_ATTACK:
			var vector_to_target: Vector2 = parent.target.global_position - parent.global_position

			if vector_to_target.y >= 0 and animation_player.current_animation != "fly":
				animation_player.play("fly")
				parent.move_child(wings, 0)
			elif vector_to_target.y < 0 and animation_player.current_animation != "fly_up":
				animation_player.play("fly_up")
				parent.move_child(wings, parent.get_child_count())

			if vector_to_target.x >= 0 and wings.flip_h:
				parent._on_change_dir()
			elif vector_to_target.x < 0 and not wings.flip_h:
				parent._on_change_dir()


func _get_transition() -> int:
	var vector_to_target: Vector2 = parent.target.global_position - parent.global_position
	match state:
		HIDDEN:
			if vector_to_target.length() < 15:
				return MELEE_ATTACK
			elif vector_to_target.length() < 50:
				return RANGED_ATTACK
		APPROACH:
			if vector_to_target.length() < 10:
				return MELEE_ATTACK
		MELEE_ATTACK:
			if not animation_player.is_playing():
				return FLEE
		FLEE:
			if vector_to_target.length() > 50:
				return RANGED_ATTACK
		RANGED_ATTACK:
			if vector_to_target.length() < 24 or insector_musk.num_consecutive_spits >= max_consecutive_spits:
				return APPROACH

	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		HIDDEN:
			parent.modulate.a = 0.25
		APPROACH:
			pathfinding_component.set_mode(PathfindingComponent.Approach.new())
		MELEE_ATTACK:
			hitbox.rotation = (insector_musk.target.global_position - insector_musk.global_position).angle()
			hitbox.knockback_direction = Vector2.RIGHT.rotated(hitbox.rotation)
			if parent.mov_direction.y >= 0:
				animation_player.play("attack")
			else:
				animation_player.play("attack_up")
		FLEE:
			pathfinding_component.set_mode(PathfindingComponent.Flee.new())
		RANGED_ATTACK:
			max_consecutive_spits = randi_range(2, 6)
			throw_acid_spit_timer.start()
			insector_musk.spit()


func _exit_state(state_exited: int) -> void:
	match state_exited:
		HIDDEN:
			insector_musk.modulate.a = 1.0
		RANGED_ATTACK:
			throw_acid_spit_timer.stop()
			insector_musk.num_consecutive_spits = 0
