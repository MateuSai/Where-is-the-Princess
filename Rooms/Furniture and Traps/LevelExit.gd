class_name LevelExit extends Area2D

## Put here the name of the biome the player will travel to. Leave empty or with the name of the current biome to not change biome, only level
@export var next_biome: String = ""

@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")

func _on_Stairs_body_entered(_body: CharacterBody2D) -> void:
	collision_shape.set_deferred("disabled", true)
	# SavedData.run_stats.level += 1
	Globals.exit_level(next_biome)
#	if SavedData.run_stats.level > SavedData.get_biome_info().levels:
#		if SavedData.get_biome_info().has("next_biome"):
#			SavedData.change_biome_by_id_or_path(SavedData.get_biome_info()["next_biome"])
#			SceneTransistor.start_transition_to("res://Game.tscn")
#		else:
#			SceneTransistor.start_transition_to("res://BaseCamp.tscn")
#	else:
#		SceneTransistor.start_transition_to("res://Game.tscn")
