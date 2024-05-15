extends NPC

var coins_to_upgrade: int

@onready var cost_hbox: HBoxContainer = $CostHBox

func _ready() -> void:
	super()

	if not SavedData.data.game_shop_exists(SavedData.data.game_shop_level + 1):
		interact_area.queue_free()
		cost_hbox.queue_free()
	else:
		coins_to_upgrade = 10 + 13 * (SavedData.data.game_shop_level - 1)
		cost_hbox.get_node("Label").text = str(coins_to_upgrade)

	cost_hbox.hide()

	interact_area.body_entered.connect(func(_player: Player) -> void:
		#canvas_modulate = CanvasModulate.new()
		#canvas_modulate.color = Color.BLACK
		#canvas_modulate.light_mask = 2
		#canvas_modulate.z_index = 100
		#get_tree().current_scene.add_child(canvas_modulate)

		#_start_dialogue("Hwy, come over here...")
		cost_hbox.show()
		if _can_interact():
			interact_area.sprite_material.set("shader_parameter/color", Color.WHITE)
			# interact_area.sprite_material.set("shader_parameter/interior_color", Color.TRANSPARENT)
		else:
			interact_area.sprite_material.set("shader_parameter/color", Color.RED)
			interact_area.sprite_material.set("shader_parameter/interior_color", Color("#8f20178d"))
	)
	interact_area.body_exited.connect(func(_player: Player) -> void:
		#canvas_modulate.queue_free()

		cost_hbox.hide()
		if not _can_interact():
			interact_area.sprite_material.set("shader_parameter/interior_color", Color.TRANSPARENT)
	)

func _on_player_interacted() -> void:
	if not _can_interact():
		return

	var window: UpgradeGameShopWindow = load("res://ui/upgrade_game_shop_window/upgrade_game_shop_window.tscn").instantiate()
	window.confirmed.connect(func() -> void:
		interact_area.queue_free()
		cost_hbox.queue_free()
		SavedData.run_stats.coins -= coins_to_upgrade
		SavedData.data.game_shop_level += 1
	)
	window.cost = coins_to_upgrade
	get_tree().current_scene.add_child(window)
	window.popup_centered()

func _can_interact() -> bool:
	return SavedData.run_stats.coins >= coins_to_upgrade