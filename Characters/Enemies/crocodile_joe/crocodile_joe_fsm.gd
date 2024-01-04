class_name CrocodileJoeFSM extends FiniteStateMachine

enum {
	ATTACK,
	FLEE,
	DEAD,
}


func start() -> void:
	set_state(ATTACK)
