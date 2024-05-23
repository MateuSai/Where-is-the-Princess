class_name DayNightFSM extends FiniteStateMachine

enum {
	SUNRISE,
	MORNING,
	AFTERNOON,
	SUNSET,
	SUNSET_END,
	NIGHT,
}

var sunrise_start_time: float
var morning_start_time: float
var afternoon_start_time: float
var sunset_start_time: float
var sunset_final_time: float
var night_start_time: float

var night_first_half_total_time: float
var night_second_half_total_time: float
var night_total_time: float

const NIGHT_COLOR: Color = Color(0.2, 0.2, 0.7, 1)
const SUNRISE_COLOR: Color = Color(0.5, 0.5, 1.0)
const SUNSET_COLOR: Color = Color.ORANGE
const NOON_COLOR: Color = Color.WHITE

var time: float = DayNightSystem.time

@onready var day_night_system: DayNightSystem = get_parent()

func start() -> void:
	if time >= sunrise_start_time and time < morning_start_time:
		set_state(SUNRISE)
	elif time >= morning_start_time and time < afternoon_start_time:
		set_state(MORNING)
	elif time >= afternoon_start_time and time < sunset_start_time:
		set_state(AFTERNOON)
	elif time >= sunset_start_time and time < sunset_final_time:
		set_state(SUNSET)
	elif time >= sunset_final_time and time < night_start_time:
		set_state(SUNSET_END)
	else:
		set_state(NIGHT)

func _state_logic(_delta: float) -> void:
	time = DayNightSystem.time

	if state in [SUNRISE, MORNING, AFTERNOON, SUNSET, SUNSET_END]:
		var normalized: float = (time - sunrise_start_time) / (night_start_time - sunrise_start_time)
		day_night_system.rotation_degrees = 90 + normalized * - 180
	else:
		assert(state == NIGHT)
		if time > night_start_time:
			var normalized: float = ((time - night_start_time) / (24.0 - night_start_time)) * (night_first_half_total_time / night_total_time)
			day_night_system.rotation_degrees = 90 + normalized * - 180
		else:
			var normalized: float = (night_first_half_total_time / night_total_time) + (time / (sunrise_start_time)) * (night_second_half_total_time / night_total_time)
			day_night_system.rotation_degrees = 90 + normalized * - 180

	match state:
		SUNRISE:
			day_night_system.color = NIGHT_COLOR.lerp(SUNRISE_COLOR, (time - sunrise_start_time) / (morning_start_time - sunrise_start_time))
		MORNING:
			day_night_system.color = SUNRISE_COLOR.lerp(NOON_COLOR, (time - morning_start_time) / (afternoon_start_time - morning_start_time))
		#AFTERNOON:
			#day_night_system.color = NOON_COLOR
		SUNSET:
			day_night_system.color = NOON_COLOR.lerp(SUNSET_COLOR, (time - sunset_start_time) / (sunset_final_time - sunset_start_time))
		SUNSET_END:
			day_night_system.color = SUNSET_COLOR.lerp(NIGHT_COLOR, (time - sunset_final_time) / (night_start_time - sunset_final_time))
		#NIGHT:
			#day_night_system.color = NIGHT_COLOR

func _get_transition() -> int:
	match state:
		NIGHT:
			if time > sunrise_start_time and time < morning_start_time:
				return SUNRISE
		SUNRISE:
			if time > morning_start_time:
				return MORNING
		MORNING:
			if time > afternoon_start_time:
				return AFTERNOON
		AFTERNOON:
			if time > sunset_start_time:
				return SUNSET
		SUNSET:
			if time > sunset_final_time:
				return SUNSET_END
		SUNSET_END:
			if time > night_start_time:
				return NIGHT

	return - 1

func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		SUNRISE:
			day_night_system.day_started.emit()
		AFTERNOON:
			day_night_system.color = NOON_COLOR
		NIGHT:
			day_night_system.color = NIGHT_COLOR

			day_night_system.night_started.emit()
