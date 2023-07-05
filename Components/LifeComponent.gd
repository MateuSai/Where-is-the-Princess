class_name LifeComponent extends Node

var invincible: bool = false

@export var hp: int:
	set(new_hp):
		hp = clamp(new_hp, 0, max_hp)
		hp_changed.emit(hp)
		if hp == 0:
			died.emit()
@export var max_hp: int = 4

signal hp_changed(new_hp: int)
signal damage_taken(dam: int, dir: Vector2, force: int)
signal died()


func take_damage(dam: int, dir: Vector2, force: int) -> void:
	if invincible:
		return

	self.hp -= dam

	damage_taken.emit(dam, dir, force)
