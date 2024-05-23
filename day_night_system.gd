class_name DayNightSystem extends DirectionalLight2D

#const TIME_SCALE: float = 0.04

var day_time_scale: float
var night_time_scale: float

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

	day_time_scale = biome_conf.day_time_scale
	night_time_scale = biome_conf.night_time_scale

	if DayNightSystem.is_day():
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
	var time_scale: float = day_time_scale if (time > 7 and time < 21) else night_time_scale
	
	time = wrapf(time + delta * time_scale, 0.0, 24.0)

static func is_day() -> bool:
	return time >= DayNightFSM.SUNRISE_START_TIME and time < DayNightFSM.SUNSET_FINAL_TIME
