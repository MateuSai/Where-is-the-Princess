class_name Crate extends StaticBody2D


@onready var sprite: Sprite2D = $Sprite2D
@onready var life_component: LifeComponent = $LifeComponent


func _ready() -> void:
	life_component.died.connect(func() -> void:
		sprite.frame = (randi() % 3) + 1
	)
