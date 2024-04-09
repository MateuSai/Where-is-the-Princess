class_name LightSnow extends WeatherModificator

func enable(player: Player) -> void:
    player.camera.add_child(load("res://shaders_and_particles/light_snow_particles.tscn").instantiate())