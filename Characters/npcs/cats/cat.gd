@icon("res://Art/cat_black_0.png")
class_name Cat extends NPC

var interacted_with: bool = false


func _on_player_interacted() -> void:
	if not interacted_with:
		interacted_with = true
		SavedData.run_stats.luck += 1
