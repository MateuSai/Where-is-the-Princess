class_name IceStatusComponent extends StatusComponent

var status_timer: Timer

var effect_time: float

func _init(effect_time: float=1.5) -> void:
	self.effect_time = effect_time

func _ready() -> void:
	if effect_time != - 1:
		status_timer = Timer.new()
		status_timer.one_shot = true
		status_timer.wait_time = effect_time
		status_timer.timeout.connect(remove)
		add_child(status_timer)

func add() -> void:
	character.modulate = Color.DEEP_SKY_BLUE

	if status_timer.is_stopped() or effect_time == - 1:
		character.max_speed -= 30
	status_timer.start()

	super()

func remove() -> void:
	character.modulate = Color.WHITE
	character.max_speed += 30
	super()
