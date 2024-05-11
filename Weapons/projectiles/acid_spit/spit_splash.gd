class_name SpitSplash extends Sprite2D

const ACID_PUDDLE_SCENE: PackedScene = preload("res://Characters/Enemies/medium_slime/acid_puddle.tscn")


func _spawn_acid_puddle() -> void:
	var acid_puddle: AcidPuddle = ACID_PUDDLE_SCENE.instantiate()
	get_tree().current_scene.add_child(acid_puddle)
	acid_puddle.global_position = global_position - acid_puddle.sprite.position
