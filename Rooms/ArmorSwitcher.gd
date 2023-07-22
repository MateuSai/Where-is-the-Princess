extends StaticBody2D


@onready var interact_area: InteractArea = get_node("InteractArea")


func _ready() -> void:
	interact_area.player_interacted.connect(_on_player_interacted)


func _on_player_interacted() -> void:
	interact_area.queue_free()
	var available_armors: Array = SavedData.data.armors_discovered.slice(1)
	Globals.player.set_armor(load(available_armors[randi() % available_armors.size()]).new())
	interact_area.player_interacted.disconnect(_on_player_interacted)
