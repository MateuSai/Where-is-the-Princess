class_name ArcheletonnFSM extends FiniteStateMachine

enum {
	IDLE,
	APPROACH,
	FLEE,
	DEAD,
}

const MAX_DISTANCE_TO_PLAYER: int = 150
const MIN_DISTANCE_TO_PLAYER: int = 40

@onready var pathfinding_component: PathfindingComponent = $"../PathfindingComponent"
@onready var bow_animation_player: AnimationPlayer = $"../BowContainer/AnimationPlayer"


func start() -> void:
	set_state(APPROACH)


func _state_logic(_delta: float) -> void:
	match state:
		IDLE:
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "idle":
				animation_player.play("idle")
			elif dir_to_player.y < 0 and animation_player.current_animation != "idle_up":
				animation_player.play("idle_up")

			if dir_to_player.x > 0 and parent.sprite.flip_h:
				parent._on_change_dir()
			elif dir_to_player.x < 0 and not parent.sprite.flip_h:
				parent._on_change_dir()
			parent.aim_bow()
		APPROACH:
			parent.move_to_target()
			#parent.move()
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif dir_to_player.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")
			parent.aim_bow()
		FLEE:
			parent.move_to_target()
			#parent.move()
			var dir_to_player: Vector2 = (parent.player.position - parent.global_position).normalized()
			if dir_to_player.y >= 0 and animation_player.current_animation != "move":
				animation_player.play("move")
			elif dir_to_player.y < 0 and animation_player.current_animation != "move_up":
				animation_player.play("move_up")


func _get_transition() -> int:
	var distance_to_player: float = (parent.player.position - parent.global_position).length()
	match state:
		IDLE:
			if distance_to_player > MAX_DISTANCE_TO_PLAYER:
				return APPROACH
			elif distance_to_player < MIN_DISTANCE_TO_PLAYER:
				return FLEE
		APPROACH:
			if distance_to_player < MAX_DISTANCE_TO_PLAYER:
				return IDLE
		FLEE:
			if distance_to_player > MIN_DISTANCE_TO_PLAYER:
				return IDLE
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		IDLE:
			if not bow_animation_player.is_playing():
				bow_animation_player.play("attack")
			#animation_player.play("idle")
		APPROACH:
			if not bow_animation_player.is_playing():
				bow_animation_player.play("attack")
			pathfinding_component.set_mode(PathfindingComponent.Approach.new())
		FLEE:
			bow_animation_player.play("RESET")
			pathfinding_component.set_mode(PathfindingComponent.Flee.new())
			#animation_player.play("move")
		DEAD:
			bow_animation_player.play("RESET")
#			# parent.spawn_loot()
#			animation_player.play("dead")

