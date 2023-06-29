@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/enemies/flying creature/fly_anim_f0.png")
extends Enemy

@onready var hitbox: Area2D = get_node("Hitbox")


func _process(_delta: float) -> void:
	hitbox.knockback_direction = velocity.normalized()

