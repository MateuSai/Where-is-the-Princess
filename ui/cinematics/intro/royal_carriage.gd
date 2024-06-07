class_name RoyalCarriage extends Node2D

@onready var wheels: Node2D = $Wheels

func _physics_process(delta: float) -> void:
    for wheel: Sprite2D in wheels.get_children():
        wheel.rotation = wrap(wheel.rotation - 1 * delta, 0.0, 2 * PI)