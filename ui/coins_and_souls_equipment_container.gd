extends HBoxContainer


@onready var coins_container: HBoxContainer = %CoinIndicatorHBoxContainer
@onready var souls_container: HBoxContainer = %SoulsIndicatorHBoxContainer


func _ready() -> void:
	(coins_container.get_node("CoinsLabel") as Label).add_theme_color_override("font_color", Color.WHITE)
	(souls_container.get_node("DarkSoulsLabel") as Label).add_theme_color_override("font_color", Color.WHITE)


func _draw() -> void:
	(coins_container.get_node("CoinsLabel") as Label).text = str(SavedData.run_stats.coins)
	(souls_container.get_node("DarkSoulsLabel") as Label).text = str(SavedData.data.dark_souls)
