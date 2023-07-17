class_name StatusInflicterComponent extends Node

@export var status: StatusComponent.Status


func _ready() -> void:
	#await owner.ready
	var hitbox: Hitbox = get_parent().hitbox
	hitbox.collided_with_something.connect(func(body: Node2D):
		if body is Character:
			body.add_status_condition(status)
	)

	match status:
		StatusComponent.Status.FIRE:
			get_parent().weapon_sprite.modulate = Color.ORANGE_RED
