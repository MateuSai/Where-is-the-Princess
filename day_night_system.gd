class_name DayNightSystem extends DirectionalLight2D

const TIME_SCALE: float = 0.04

signal day_started()
signal night_started()

static var time: float = 12

@onready var game: Game = get_parent()
@onready var fsm: FiniteStateMachine = $DayNightFSM
@onready var update_timer: Timer = $UpdateTimer

func _ready() -> void:
	var biome_conf: BiomeConf = SavedData.get_biome_conf()
	if not biome_conf.day_night_cycle:
		hide()
		return

	fsm.sunrise_start_time = biome_conf.sunrise_start_time
	fsm.morning_start_time = biome_conf.morning_start_time
	fsm.afternoon_start_time = biome_conf.afternoon_start_time
	fsm.sunset_start_time = biome_conf.sunset_start_time
	fsm.sunset_final_time = biome_conf.sunset_final_time
	fsm.night_start_time = biome_conf.night_start_time

	fsm.night_first_half_total_time = 24.0 - fsm.night_start_time
	fsm.night_second_half_total_time = fsm.sunrise_start_time
	fsm.night_total_time = fsm.night_first_half_total_time + fsm.night_second_half_total_time

	if is_day():
		day_started.emit()
	else:
		night_started.emit()

	game.player_added.connect(func() -> void:
		fsm.start()
		update_timer.timeout.connect(func() -> void:
			fsm.physics_process(update_timer.wait_time)
		)
		update_timer.start()
	)

func _process(delta: float) -> void:
	time = wrapf(time + delta * TIME_SCALE, 0.0, 24.0)

func is_day() -> bool:
	return time >= fsm.sunrise_start_time and time < fsm.sunset_final_time
