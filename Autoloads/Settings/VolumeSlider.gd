class_name VolumeSlider extends HSlider

@export_enum("Master", "Music", "Sounds") var bus: String


func _init() -> void:
	max_value = 1.0
	step = 0.1

	value_changed.connect(_on_value_changed)


func _ready() -> void:
	assert(bus)

	value = db_to_linear(owner.settings.get_value("Audio", bus.to_lower() + "_volume", 0))

	# value = owner.settings[bus.to_lower() + "_volume"]


func _on_value_changed(new_value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear_to_db(new_value))
