class_name PracticeDummy extends Character


func _ready() -> void:
	super()
	life_component.invincible_after_being_hitted_time = 0.1


func _on_damage_taken(dam: int, dir: Vector2, force: int) -> void:
	super(dam, dir, force)

	life_component.hp += dam # So the dummy never dies

	animation_player.stop()
	animation_player.play("damage", 0)
