class_name DayNightFSM extends FiniteStateMachine

enum {
	SUNRISE,
	MORNING,
	AFTERNOON,
	SUNSET,
	SUNSET_END,
	NIGHT,
}

const SUNRISE_START_TIME: float = 7.0
const MORNING_START_TIME: float = 8.0
const AFTERNOON_START_TIME: float = 14.0
const SUNSET_START_TIME: float = 18.0
const SUNSET_FINAL_TIME: float = 19.5
const NIGHT_START_TIME: float = 21.0

const NIGHT_FIRST_HALF_TOTAL_TIME: float = 24.0 - NIGHT_START_TIME
const NIGHT_SECOND_HALF_TOTAL_TIME: float = SUNRISE_START_TIME
const NIGHT_TOTAL_TIME: float = NIGHT_FIRST_HALF_TOTAL_TIME + NIGHT_SECOND_HALF_TOTAL_TIME

const NIGHT_COLOR: Color = Color(0.2, 0.2, 0.7, 1)
const SUNRISE_COLOR: Color = Color(0.5, 0.5, 1.0)
# TODO
const SUNSET_COLOR: Color = Color.ORANGE
const NOON_COLOR: Color = Color.WHITE

var time: float = DayNightSystem.time


@onready var day_night_system: DayNightSystem = get_parent()


func start() -> void:
	if time >= SUNRISE_START_TIME and time < MORNING_START_TIME:
		set_state(SUNRISE)
	elif time >= MORNING_START_TIME and time < AFTERNOON_START_TIME:
		set_state(MORNING)
	elif time >= AFTERNOON_START_TIME and time < SUNSET_START_TIME:
		set_state(AFTERNOON)
	elif time >= SUNSET_START_TIME and time < SUNSET_FINAL_TIME:
		set_state(SUNSET)
	elif time >= SUNSET_FINAL_TIME and time < NIGHT_START_TIME:
		set_state(SUNSET_END)
	else:
		set_state(NIGHT)


func _state_logic(_delta: float) -> void:
	time = DayNightSystem.time

	if state in [SUNRISE, MORNING, AFTERNOON, SUNSET, SUNSET_END]:
		var normalized: float = (time - SUNRISE_START_TIME) / (NIGHT_START_TIME - SUNRISE_START_TIME)
		day_night_system.rotation_degrees = 90 + normalized * -180
	else:
		assert(state == NIGHT)
		if time > NIGHT_START_TIME:
			var normalized: float = ((time - NIGHT_START_TIME) / (24.0 - NIGHT_START_TIME)) * (NIGHT_FIRST_HALF_TOTAL_TIME / NIGHT_TOTAL_TIME)
			day_night_system.rotation_degrees = 90 + normalized * -180
		else:
			var normalized: float = (NIGHT_FIRST_HALF_TOTAL_TIME / NIGHT_TOTAL_TIME) + (time / (SUNRISE_START_TIME)) * (NIGHT_SECOND_HALF_TOTAL_TIME / NIGHT_TOTAL_TIME)
			day_night_system.rotation_degrees = 90 + normalized * -180

	match state:
		SUNRISE:
			day_night_system.color = NIGHT_COLOR.lerp(SUNRISE_COLOR, (time - SUNRISE_START_TIME) / (MORNING_START_TIME - SUNRISE_START_TIME))
		MORNING:
			day_night_system.color = SUNRISE_COLOR.lerp(NOON_COLOR, (time - MORNING_START_TIME) / (AFTERNOON_START_TIME - MORNING_START_TIME))
		#AFTERNOON:
			#day_night_system.color = NOON_COLOR
		SUNSET:
			day_night_system.color = NOON_COLOR.lerp(SUNSET_COLOR, (time - SUNSET_START_TIME) / (SUNSET_FINAL_TIME - SUNSET_START_TIME))
		SUNSET_END:
			day_night_system.color = SUNSET_COLOR.lerp(NIGHT_COLOR, (time - SUNSET_FINAL_TIME) / (NIGHT_START_TIME - SUNSET_FINAL_TIME))
		#NIGHT:
			#day_night_system.color = NIGHT_COLOR


func _get_transition() -> int:
	match state:
		NIGHT:
			if time > SUNRISE_START_TIME and time < MORNING_START_TIME:
				return SUNRISE
		SUNRISE:
			if time > MORNING_START_TIME:
				return MORNING
		MORNING:
			if time > AFTERNOON_START_TIME:
				return AFTERNOON
		AFTERNOON:
			if time > SUNSET_START_TIME:
				return SUNSET
		SUNSET:
			if time > SUNSET_FINAL_TIME:
				return SUNSET_END
		SUNSET_END:
			if time > NIGHT_START_TIME:
				return NIGHT

	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		SUNRISE_START_TIME:
			day_night_system.day_started.emit()
		AFTERNOON:
			day_night_system.color = NOON_COLOR
		NIGHT:
			day_night_system.color = NIGHT_COLOR

			day_night_system.night_started.emit()
