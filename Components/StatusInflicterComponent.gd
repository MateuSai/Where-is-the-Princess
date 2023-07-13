class_name StatusInflicterComponent extends Node

@export var status: StatusComponent.Status


func _ready() -> void:
	await owner.ready
	var hitbox: Hitbox = owner.hitbox
	hitbox.collided_with_something.connect(func(body: Node2D):
		if body is Character:
			body.add_status_condition(status)
	)
