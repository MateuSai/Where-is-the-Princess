@tool

class_name StuckDetector extends Node2D

var damage_timer: Timer

@onready var life_component: LifeComponent = get_parent().get_node("LifeComponent")

func _ready() -> void:
	for dir: Vector2i in [Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN]:
		var raycast: RayCast2D = RayCast2D.new()
		raycast.hit_from_inside = true
		raycast.target_position = dir * 3
		add_child(raycast)

	damage_timer = Timer.new()
	damage_timer.name = "StuckDamageTimer"
	damage_timer.wait_time = 1
	damage_timer.timeout.connect(func() -> void:
		life_component.take_damage(1, Vector2.ZERO, 0, null, null, "wall")
	)
	get_parent().call_deferred("add_child", damage_timer)

func _physics_process(_delta: float) -> void:
	var is_stuck: bool = true
	for raycast: RayCast2D in get_children():
		if not raycast.is_colliding():
			Log.debug("Raycast " + str(raycast.get_index()) + " is NOT colliding")
			is_stuck = false
			break
		Log.debug("Raycast " + str(raycast.get_index()) + " is colliding")

	if is_stuck and damage_timer.is_stopped():
		Log.debug("Starting stuck damage timer...")
		damage_timer.start()
	elif not is_stuck and not damage_timer.is_stopped():
		Log.debug("Stopping stuck damage timer...")
		damage_timer.stop()
