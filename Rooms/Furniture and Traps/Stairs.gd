extends Area2D

@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")

func _on_Stairs_body_entered(_body: CharacterBody2D) -> void:
	collision_shape.set_deferred("disabled", true)
	SavedData.run_stats.level += 1
	if SavedData.run_stats.level > SavedData.biomes_path[SavedData.run_stats.biome].levels:
		SceneTransistor.start_transition_to("res://BaseCamp.tscn")
	else:
		SceneTransistor.start_transition_to("res://Game.tscn")
