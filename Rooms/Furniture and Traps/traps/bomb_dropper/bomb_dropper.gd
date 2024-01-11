class_name BombDropper extends Sprite2D


const BOMB_VERTICAL_DROP_SCENE: PackedScene = preload("res://Weapons/projectiles/bombs/bomb_vertical_drop.tscn")


func activate() -> void:
	var bomb_vertical_drop: BombVerticalDrop = BOMB_VERTICAL_DROP_SCENE.instantiate()
	bomb_vertical_drop.position = position
	get_parent().call_deferred("add_child", bomb_vertical_drop)
	bomb_vertical_drop.call_deferred("start")
