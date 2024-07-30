extends Control

func _ready() -> void:
	if not SavedData.data.is_npc_killed("diogenes"):
		$Diogenes.queue_free()
