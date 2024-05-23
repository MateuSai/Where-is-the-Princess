class_name Campfire extends StaticBody2D

@onready var day_night_system: DayNightSystem = get_tree().current_scene.get_node("%DayNightSystem")

@onready var steam_spawner: SteamSpawner = $SteamSpawner
@onready var light: PointLight2D = $PointLight2D
@onready var fire: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var temperature_area_collision: CollisionShape2D = $TemperatureArea/CollisionShape2D

func _ready() -> void:
	if SavedData.get_biome_conf().day_night_cycle:
		if day_night_system.is_day():
			_disable()
		else:
			_enable()

		day_night_system.day_started.connect(func() -> void:
			_disable()
		)
		day_night_system.night_started.connect(func() -> void:
			_enable()
		)

func _enable() -> void:
	steam_spawner.start()
	light.enabled = true
	fire.show()
	sound.play()
	temperature_area_collision.disabled = false

func _disable() -> void:
	steam_spawner.stop()
	light.enabled = false
	fire.hide()
	sound.stop()
	temperature_area_collision.disabled = true
