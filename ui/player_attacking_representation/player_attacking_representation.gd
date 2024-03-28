class_name PlayerAttackingRepresentation extends Control

@onready var player: Sprite2D = $Player


func initialize(weapon_path: String) -> void:
	player.texture = Globals.player.sprite.texture

