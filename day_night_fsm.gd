class_name DayNightFSM extends FiniteStateMachine

enum {
	SUNRISE,
	MORNING,
	AFTERNOON,
	SUNSET,
	NIGHT,
}

const SUNRISE_TIME: float = 7.0
const MORNING_TIME: float = 8.0
const AFTERNOON_TIME: float = 14.0
const SUNSET_TIME: float = 19.0
const NIGHT_TIME: float = 21.0

const NIGHT_COLOR: Color = Color.DARK_BLUE
const SUNRISE_COLOR: Color = Color.ORANGE
const NOON_COLOR: Color = Color.WHITE

var time: float = 7.0


@onready var day_night_system: DayNightSystem = get_parent()


func start() -> void:
	if time >= SUNRISE_TIME and time < MORNING_TIME:
		set_state(SUNRISE)
	elif time >= MORNING_TIME and time < AFTERNOON_TIME:
		set_state(MORNING)
	elif time >= AFTERNOON_TIME and time < SUNSET_TIME:
		set_state(AFTERNOON)
	elif time >= SUNSET_TIME and time < NIGHT_TIME:
		set_state(SUNSET)
	else:
		set_state(NIGHT)


func _state_logic(delta: float) -> void:
	time = wrapf(time + delta, 0.0, 24.0)
	DayNightSystem.time = time

	if state in [SUNRISE, MORNING, AFTERNOON, SUNSET]:
		var normalized: float = (time - SUNRISE_TIME) / (NIGHT_TIME - SUNRISE_TIME)
		day_night_system.rotation_degrees = 90 + normalized * -180

	match state:
		SUNRISE:
			day_night_system.color = NIGHT_COLOR.lerp(SUNRISE_COLOR, (time - SUNRISE_TIME) / (MORNING_TIME - SUNRISE_TIME))
		MORNING:
			day_night_system.color = SUNRISE_COLOR.lerp(NOON_COLOR, (time - MORNING_TIME) / (AFTERNOON_TIME - MORNING_TIME))
		#AFTERNOON:
			#day_night_system.color = NOON_COLOR
		SUNSET:
			day_night_system.color = NOON_COLOR.lerp(NIGHT_COLOR, (time - SUNSET_TIME) / (NIGHT_TIME - SUNSET_TIME))
		#NIGHT:
			#day_night_system.color = NIGHT_COLOR


func _get_transition() -> int:
	match state:
		NIGHT:
			if time > SUNRISE_TIME and time < MORNING_TIME:
				return SUNRISE
		SUNRISE:
			if time > MORNING_TIME:
				return MORNING
		MORNING:
			if time > AFTERNOON_TIME:
				return AFTERNOON
		AFTERNOON:
			if time > SUNSET_TIME:
				return SUNSET
		SUNSET:
			if time > SUNSET_TIME:
				return NIGHT

	return -1


func _enter_state(_previous_state: int, new_state: int) -> void:
	match new_state:
		AFTERNOON:
			day_night_system.color = NOON_COLOR
		NIGHT:
			day_night_system.color = NIGHT_COLOR
