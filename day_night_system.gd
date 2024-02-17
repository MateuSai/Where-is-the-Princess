class_name DayNightSystem extends DirectionalLight2D

const TIME_SCALE: float = 1.0

static var time: float = 7.0

@onready var game: Game = get_parent()
@onready var fsm: FiniteStateMachine = $DayNightFSM
@onready var update_timer: Timer = $UpdateTimer


func _ready() -> void:
	if not SavedData.get_biome_conf().day_night_cycle:
		hide()
		return

	game.player_added.connect(func() -> void:
		fsm.start()
		update_timer.timeout.connect(func() -> void:
			fsm.physics_process(update_timer.wait_time)
		)
		update_timer.start()
	)


func _process(delta: float) -> void:
	time = wrapf(time + delta * TIME_SCALE, 0.0, 24.0)
