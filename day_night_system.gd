class_name DayNightSystem extends DirectionalLight2D

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

#const SUNRISE_TIME: float = 0.15
#const NOON_TIME: float = 0.7
#const SUNSET_TIME: float = 0.15
#const DAY_TIME: float = 12.0
#const NIGHT_TIME: float = 8.0

const NIGHT_COLOR: Color = Color.DARK_BLUE
const SUNRISE_COLOR: Color = Color.ORANGE
const NOON_COLOR: Color = Color.WHITE

static var tween: Tween

static var time: float = 7.0:
	set(new_time):
		time = new_time
		if time > SUNRISE_TIME and time < MORNING_TIME:
			day_time = SUNRISE_TIME
		elif time > MORNING_TIME and time < AFTERNOON_TIME:
			day_time = MORNING
		elif time > AFTERNOON_TIME and time < SUNSET_TIME:
			day_time = SUNSET
		elif time > SUNSET_TIME or time < SUNRISE_TIME:
			day_time = NIGHT

static var day_time: int = SUNRISE

@onready var game: Game = get_parent()
@onready var fsm: FiniteStateMachine = $DayNightFSM


func _ready() -> void:
	set_physics_process(false)

	if not SavedData.get_biome_conf().day_night_cycle:
		hide()
		return

	game.player_added.connect(func() -> void:
		set_physics_process(true)
		fsm.start()
		#if is_instance_valid(tween):
			#tween.bind_node(self)
			#tween.play()
		#else:
			#tween = create_tween()
			#tween.set_loops()
			#tween.set_parallel()
#
			#tween.tween_callback(func() -> void: rotation_degrees = -90)
			#tween.tween_callback(func() -> void: color = NIGHT_COLOR)
#
			#tween.chain()
			#tween.tween_property(self, "rotation_degrees", -90 + 180 * SUNRISE_TIME, SUNRISE_TIME * DAY_TIME)
			#tween.tween_property(self, "color", SUNRISE_COLOR, SUNRISE_TIME * DAY_TIME)
#
			#tween.chain()
			#tween.tween_property(self, "rotation_degrees", -90 + 180 * SUNRISE_TIME + 180 * NOON_TIME, NOON_TIME * DAY_TIME)
			#tween.tween_property(self, "color", NOON_COLOR, NOON_TIME * DAY_TIME)
#
			#tween.chain()
			#tween.tween_property(self, "rotation_degrees", -90 + 180 * SUNRISE_TIME + 180 * NOON_TIME + 180 * SUNSET_TIME, SUNSET_TIME * DAY_TIME)
			#tween.tween_property(self, "color", NIGHT_COLOR, SUNSET_TIME * DAY_TIME)
#
			#tween.chain()
			#tween.tween_property(self, "rotation_degrees", -90 + 360, NIGHT_TIME)
	)


func _physics_process(delta: float) -> void:
	time = wrapf(time + delta, 0.0, 24.0)


#func _exit_tree() -> void:
	#tween.pause()
	#tween.bind_node(null)
