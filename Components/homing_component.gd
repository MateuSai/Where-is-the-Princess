class_name HomingComponent extends Area2D


func _ready() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(3, true) # enemies
