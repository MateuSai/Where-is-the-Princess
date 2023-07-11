extends VBoxContainer


@onready var coins_label: Label = get_node("HBoxContainer/CoinsLabel")


func _ready() -> void:
	SavedData.run_stats.coins_changed.connect(func(new_coins: int):
		coins_label.text = str(new_coins)
	)
	coins_label.text = "0"
