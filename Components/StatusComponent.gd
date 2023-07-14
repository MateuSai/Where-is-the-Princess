class_name StatusComponent extends Node

var life_component: LifeComponent

var damage_timer: Timer

enum Status {
	FIRE,
}

var max_charges: int
var charges: int


@warning_ignore("shadowed_variable_base_class", "shadowed_variable")
func initialize(charges: int) -> void:
	max_charges = charges


#func _init() -> void:
#	fill_mode = FILL_BOTTOM_TO_TOP


func _ready() -> void:
	life_component = get_node_or_null("../LifeComponent")
	assert(life_component != null)

	damage_timer = Timer.new()
	damage_timer.wait_time = 0.8
	damage_timer.timeout.connect(_on_damage_timer_timeout)
	add_child(damage_timer)


func add() -> void:
	charges = max_charges

	if damage_timer.is_stopped():
		damage_timer.start()
		_on_damage_timer_timeout()


func remove() -> void:
	queue_free()


func _on_damage_timer_timeout() -> void:
	life_component.take_damage(1, Vector2.ZERO, 0)
	charges -= 1
	if charges == 0:
		remove()
