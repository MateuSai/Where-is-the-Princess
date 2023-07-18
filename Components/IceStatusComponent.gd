class_name IceStatusComponent extends StatusComponent


var status_timer: Timer


func _ready() -> void:
	status_timer = Timer.new()
	status_timer.one_shot = true
	status_timer.wait_time = 1.5
	status_timer.timeout.connect(remove)
	add_child(status_timer)


func add() -> void:
	get_parent().modulate = Color.DEEP_SKY_BLUE

	if status_timer.is_stopped():
		get_parent().max_speed -= 30
	status_timer.start()

	super()


func remove() -> void:
	get_parent().modulate = Color.WHITE
	get_parent().max_speed += 30
	super()
