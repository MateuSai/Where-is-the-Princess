class_name Campfire extends StaticBody2D


@onready var day_night_system: DayNightSystem = get_tree().current_scene.get_node("%DayNightSystem")

@onready var steam_spawner: SteamSpawner = $SteamSpawner
@onready var light: PointLight2D = $PointLight2D
@onready var fire: AnimatedSprite2D = $AnimatedSprite2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D


func _ready() -> void:
	if SavedData.get_biome_conf().day_night_cycle:
		if DayNightSystem.is_day():
			steam_spawner.stop()
			light.enabled = false
			fire.hide()
			sound.stop()
		else:
			steam_spawner.start()
			light.enabled = true
			fire.show()
			sound.play()

		day_night_system.day_started.connect(func() -> void:
			steam_spawner.stop()
			light.enabled = false
			fire.hide()
			sound.stop()
		)
		day_night_system.night_started.connect(func() -> void:
			steam_spawner.start()
			light.enabled = true
			fire.show()
			sound.play()
		)
