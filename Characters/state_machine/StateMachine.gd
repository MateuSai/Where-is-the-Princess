class_name StateMachine

var current_state: State = null : set = set_current_state

var states: Dictionary = {}


func add_state(state: State) -> void:
	states[state.name] = state


func update(delta: float) -> void:
	if current_state != null:
		var transition: String = current_state.get_transition.call()
		if transition != "":
			set_current_state(states[transition])
		else:
			current_state.update.call()


func set_current_state(new_state: State) -> void:
	if current_state != null and not current_state.exit.is_null():
		current_state.exit.call()
	current_state = new_state
	if current_state != null:
		current_state.enter.call()
