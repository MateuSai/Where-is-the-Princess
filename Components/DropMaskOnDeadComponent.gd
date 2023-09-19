class_name DropMaskOnDeadComponent extends Node

@onready var enemy: Enemy = owner


func _ready() -> void:
	enemy.get_node("LifeComponent").died.connect(_spawn_mask)


func _spawn_mask() -> void:
	var tribal_mask: TribalMask = TribalMask.new()
	var flip_h: bool = enemy.get_node("Sprite2D").flip_h

	if enemy is BlowpipeTribal:
		tribal_mask.initialize(tribal_mask.Type.BLOWPIPE, flip_h)
	elif enemy is SpearTribal:
		tribal_mask.initialize(tribal_mask.Type.SPEAR, flip_h)
	elif enemy is BombTribal:
		tribal_mask.initialize(tribal_mask.Type.BOMB, flip_h)
	elif enemy is ShamanTribal:
		tribal_mask.initialize(tribal_mask.Type.SHAMAN, flip_h)
	else:
		printerr("Error: Invalid parent for DropMaskOnDeadComponent component")

	tribal_mask.position = enemy.global_position
	get_tree().current_scene.add_child(tribal_mask)
