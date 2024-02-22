class_name PoopSlime extends Enemy


const POOP_PUDLE_SCENE: PackedScene = preload("res://Characters/Enemies/poop_slime/poop_puddle.tscn")


func _ready() -> void:
	super()

	life_component.died.connect(func() -> void:
		for i: int in ((randi() % 3) + 2):
			var poop_puddle: Node2D = POOP_PUDLE_SCENE.instantiate()
			poop_puddle.global_position = global_position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
			get_tree().current_scene.call_deferred("add_child", poop_puddle)

		var insecton_musk: InsectonMusk = load(Globals.ENEMIES["insecton_musk"].path).instantiate()
		insecton_musk.position = position
		room.call_deferred("add_enemy", insecton_musk)
	)
