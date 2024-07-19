class_name CooldownProcessTimerDecorator extends Decorator

var time: float = 0.0
var cooldown_ended: bool = true

@export var wait_time := 0.0

@onready var cache_key: String = 'cooldown_%s' % self.get_instance_id()

func _process(delta: float) -> void:
	time += delta

	if time >= wait_time:
		cooldown_ended = true
		set_process(false)

func tick(actor: Node, blackboard: Blackboard) -> int:
	var c: BeehaveNode = get_child(0)
	var response: int

	if c != running_child:
		c.before_run(actor, blackboard)

	if not cooldown_ended:
		response = FAILURE

		blackboard.set_value(cache_key, wait_time - time, str(actor.get_instance_id()))
	else:
		response = c.tick(actor, blackboard)

		if c is ConditionLeaf:
			blackboard.set_value("last_condition", c, str(actor.get_instance_id()))
			blackboard.set_value("last_condition_status", response, str(actor.get_instance_id()))

		if response == RUNNING and c is ActionLeaf:
			running_child = c
			blackboard.set_value("running_action", c, str(actor.get_instance_id()))

		if response != RUNNING:
			blackboard.set_value(cache_key, wait_time, str(actor.get_instance_id()))
			time = 0.0
			cooldown_ended = false
			set_process(true)

	if can_send_message(blackboard):
		BeehaveDebuggerMessages.process_tick(self.get_instance_id(), response)

	return response
