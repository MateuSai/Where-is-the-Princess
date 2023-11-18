class_name FireStatusComponent extends StatusComponent


var damage_timer: Timer

var max_charges: int
var charges: int


func _init() -> void:
	max_charges = 2


func _ready() -> void:
	super()
	damage_timer = Timer.new()
	damage_timer.wait_time = 0.8
	damage_timer.timeout.connect(_on_damage_timer_timeout)
	add_child(damage_timer)


func add() -> void:
	get_parent().modulate = Color.RED

	charges = max_charges

	if damage_timer.is_stopped():
		damage_timer.start()
		_on_damage_timer_timeout()

	super()


func remove() -> void:
	get_parent().modulate = Color.WHITE
	super()


func _on_damage_timer_timeout() -> void:
	life_component.take_damage(1 + Globals.player.extra_fire_damage, Vector2.ZERO, 0, null)
	charges -= 1
	if charges == 0:
		remove()
