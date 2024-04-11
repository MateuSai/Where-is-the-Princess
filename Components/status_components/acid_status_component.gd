class_name AcidStatusComponent extends StatusComponent

func add() -> void:
    var acid_puddle: Area2D = load("res://Characters/Enemies/MediumSlime/acid_puddle.tscn").instantiate()
    acid_puddle.position = character.global_position + Vector2(randf_range( - 8, 8), randf_range( - 8, 8))
    get_tree().current_scene.add_child(acid_puddle)

    remove()