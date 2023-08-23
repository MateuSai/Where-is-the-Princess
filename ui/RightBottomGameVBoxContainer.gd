extends VBoxContainer

var transparency_tween: Tween

@onready var coins_label: Label = get_node("HBoxContainer/CoinsLabel")
@onready var souls_label: Label = $HBoxContainer2/SoulsLabel


func _ready() -> void:
	SavedData.run_stats.coins_changed.connect(func(new_coins: int):
		coins_label.text = str(new_coins)
	)
	coins_label.text = str(SavedData.run_stats.coins)

	SavedData.run_stats.souls_changed.connect(func(new_souls: int):
		souls_label.text = str(new_souls) + "/" + str(SavedData.run_stats.max_souls)
	)
	souls_label.text = str(SavedData.run_stats.souls) + "/" + str(SavedData.run_stats.max_souls)

	Globals.room_closed.connect(_on_room_closed)
	Globals.room_cleared.connect(_on_room_cleared)


func _on_room_closed() -> void:
	if transparency_tween != null:
		transparency_tween.kill()

	transparency_tween = create_tween()
	transparency_tween.tween_property(self, "modulate:a", 0.0, 0.7)


func _on_room_cleared() -> void:
	if transparency_tween != null:
		transparency_tween.kill()

	transparency_tween = create_tween()
	transparency_tween.tween_property(self, "modulate:a", 1.0, 0.7)
