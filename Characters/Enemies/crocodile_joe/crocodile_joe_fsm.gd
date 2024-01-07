class_name CrocodileJoeFSM extends FiniteStateMachine

enum {
	LONG_RANGE,
	CLOSE_RANGE,
	DEAD,
}

const DISTANCE_TO_CHANGE_RANGE: int = 10

@onready var joe: CrocodileJoe = get_parent()
@onready var pathfinding_component: PathfindingComponent = $"../PathfindingComponent"
@onready var weapons: EnemyWeapons = $"../EnemyWeapons"


func start() -> void:
	set_state(LONG_RANGE)


func _state_logic(_delta: float) -> void:
	match state:
		LONG_RANGE:
			weapons.move((joe.target.global_position - joe.global_position).normalized())
			if not weapons.is_busy():
				if weapons.current_weapon.weapon_sprite.frame == Crossbow.RELEASED_FRAME:
					weapons.reload()
				else:
					weapons.attack()

			joe.move_to_target()
			joe.move()


func _get_transition() -> int:
	match state:
		LONG_RANGE:
			var distance_to_target: float = (joe.target.global_position - joe.global_position).length()
			if distance_to_target < DISTANCE_TO_CHANGE_RANGE:
				return CLOSE_RANGE
		CLOSE_RANGE:
			var distance_to_target: float = (joe.target.global_position - joe.global_position).length()
			if distance_to_target > DISTANCE_TO_CHANGE_RANGE:
				return LONG_RANGE
	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		LONG_RANGE:
			pathfinding_component.set_mode(PathfindingComponent.Wander.new())
