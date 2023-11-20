class_name SpitSplash extends Sprite2D

const ACID_PUDDLE_SCENE: PackedScene = preload("res://Characters/Enemies/MediumSlime/acid_puddle.tscn")


func _spawn_acid_puddle() -> void:
	var acid_puddle: AcidPuddle = ACID_PUDDLE_SCENE.instantiate()
	acid_puddle.global_position = global_position
	get_tree().current_scene.add_child(acid_puddle)
