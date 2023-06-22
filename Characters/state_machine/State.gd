class_name State

var name: String
var get_transition: Callable
var update: Callable
var enter: Callable
var exit: Callable

@warning_ignore("shadowed_variable")
func _init(name: String, get_transition: Callable = Callable(), update: Callable = Callable(), enter: Callable = Callable(), exit: Callable = Callable()) -> void:
	self.name = name
	self.get_transition = get_transition
	self.update = update
	self.enter = enter
	self.exit = exit
