class_name CircleTarget extends ActionLeaf

var timer: Timer

@export var close_limit: float = 3.0
@export var far_limit: float = 16.0
@export var time_limit: float = -1

func _ready() -> void:
	if time_limit > 0:
		timer = Timer.new()
		timer.one_shot = true
		add_child(timer)

func tick(actor: Node, _blackboard: Blackboard) -> int:
	#Log.debug("CircleTarget tick")

	if time_limit != - 1 and timer.is_stopped():
		#Log.debug("CircleTarget SUCCESS")
		return SUCCESS

	actor.move_to_target()

	var vec_to_target: Vector2 = ((actor as Enemy).target.global_position - (actor as Enemy).global_position)
	if vec_to_target.length() < close_limit or vec_to_target.length() > far_limit:
		#Log.debug("CircleTarget FAILURE. vec_to_target: " + str(vec_to_target))
		return FAILURE

	#if actor.mov_direction.y >= 0 and actor.animation_player.current_animation != "idle":
	#	actor.animation_player.play("idle")
	#elif actor.mov_direction.y < 0 and actor.animation_player.current_animation != "idle_up":
	#	actor.animation_player.play("idle_up")

	return RUNNING

func before_run(actor: Node, _blackboard: Blackboard) -> void:
	#Log.debug("CircleTarget before_run")

	if time_limit > 0:
		timer.wait_time = time_limit
		timer.start()

	if not (actor.get_node("PathfindingComponent") as PathfindingComponent).mode is PathfindingComponent.Circle:
		(actor.get_node("PathfindingComponent") as PathfindingComponent).mode = PathfindingComponent.Circle.new()

func after_run(actor: Node, _blackboard: Blackboard) -> void:
	(actor as Enemy).mov_direction = Vector2.ZERO
