class_name Torch extends PointLight2D


@onready var day_night_system: DayNightSystem = get_tree().current_scene.get_node("%DayNightSystem")

@onready var fire: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if SavedData.get_biome_conf().day_night_cycle:
		if DayNightSystem.is_day():
			enabled = false
			fire.hide()
		else:
			enabled = true
			fire.show()

		day_night_system.day_started.connect(func() -> void:
			enabled = false
			fire.hide()
		)
		day_night_system.night_started.connect(func() -> void:
			enabled = true
			fire.show()
		)
