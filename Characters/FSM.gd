extends Node
class_name FiniteStateMachine

var previous_state: int = -1
var state: int = -1: set = set_state
signal state_changed(new_state: int)

@onready var parent: Node = get_parent()
@onready var animation_player: AnimationPlayer = parent.get_node_or_null("AnimationPlayer")


func start() -> void:
	pass


func physics_process(delta: float) -> void:
	if state != -1:
		_state_logic(delta)
		var transition: int = _get_transition()
		if transition != -1:
			set_state(transition)


func _state_logic(_delta: float) -> void:
	pass


func _get_transition() -> int:
	return -1


func set_state(new_state: int) -> void:
	#print(new_state)
	_exit_state(state)
	previous_state = state
	state = new_state
	state_changed.emit(state)
	_enter_state(previous_state, state)


func _enter_state(_previous_state: int, _new_state: int) -> void:
	pass


func _exit_state(_state_exited: int) -> void:
	pass
