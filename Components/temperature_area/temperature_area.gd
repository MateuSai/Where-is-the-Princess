class_name TemperatureArea extends Area2D

@export var temperature: float = 20.0

func _init() -> void:
    body_entered.connect(func(player: Player) -> void:
        player.close_temperatures.push_back(temperature)
    )
    body_exited.connect(func(player: Player) -> void:
        player.close_temperatures.erase(temperature)
    )
