class_name MercenarySpawner extends Marker2D


func _ready() -> void:
	if randi() % 2 == 0:
		var mercenary: StaticBody2D = (load("res://Characters/npcs/mercenary/mercenary.tscn") as PackedScene).instantiate()
		mercenary.position = position
		get_parent().call_deferred("add_child", mercenary)

	queue_free()
