class_name WoodenFence extends StaticBody2D

const DESTROYED_DIF: int = 5

@onready var sprite: Sprite2D = $Sprite2D
@onready var life_component: LifeComponent = get_node("LifeComponent")

func _ready() -> void:
	life_component.died.connect(func() -> void:
		sprite.frame_coords.x += DESTROYED_DIF
	)
	
