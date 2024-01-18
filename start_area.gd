class_name StartArea extends Area2D

@onready var base_camp: BaseCamp = owner
@onready var color_rect: ColorRect = %ColorRect


func _ready() -> void:
	body_exited.connect(func(body: Node2D) -> void:
		assert(body is Player)
		if body.position.y > position.y:
			color_rect.color.a = clamp(color_rect.color.a - 0.25, 0.0, 1.0)
		else:
			color_rect.color.a = clamp(color_rect.color.a + 0.25, 0.0, 1.0)
			if color_rect.color.a == 1.0:
				Globals.exit_level("forest")
	)
