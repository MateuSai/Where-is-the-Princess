class_name MoveToTarget extends ActionLeaf

var timer: Timer

@export var closer_than: int = 8
@export var time_limit: float = -1

func _ready() -> void:
	if time_limit > 0:
		timer = Timer.new()
		timer.one_shot = true
		add_child(timer)

func tick(actor: Node, _blackboard: Blackboard) -> int:
	if time_limit != - 1 and timer.is_stopped():
		return SUCCESS

	actor.move_to_target()
	#actor.move()

	if ((actor as Enemy).target.global_position - (actor as Enemy).global_position).length() < closer_than:
		if actor.mov_direction.y >= 0 and actor.animation_player.current_animation != "idle":
			actor.animation_player.play("idle")
		elif actor.mov_direction.y < 0 and actor.animation_player.current_animation != "idle_up":
			actor.animation_player.play("idle_up")

		return SUCCESS

	return RUNNING

func before_run(_actor: Node, _blackboard: Blackboard) -> void:
	if time_limit > 0:
		timer.wait_time = time_limit
		timer.start()

func after_run(actor: Node, _blackboard: Blackboard) -> void:
	(actor as Enemy).mov_direction = Vector2.ZERO