extends Node2D

@onready var player: Player = get_node("Player")
@onready var start_interact_area: InteractArea = get_node("StartInteractArea")
@onready var wardrobe_interact_area: InteractArea = get_node("Wardrobe/WardrobeInteractArea")
@onready var settings_interact_area: InteractArea = $Settings/SettingsInteractArea
@onready var exit_interact_area: InteractArea = get_node("ExitInteractArea")
@onready var wardrobe_popup: Popup = get_node("WardrobePopup")


func _ready() -> void:
	player.set_armor(load(SavedData.data.equipped_armor).new())

	start_interact_area.player_interacted.connect(func():
		SceneTransistor.start_transition_to("res://Game.tscn")
	)

	settings_interact_area.player_interacted.connect(func():
		Settings.popup_centered()
		player.can_move = false
	)
	Settings.popup_hide.connect(func():
		player.can_move = true
	)

	exit_interact_area.player_interacted.connect(func():
		get_tree().quit()
	)

	wardrobe_interact_area.player_interacted.connect(func():
		wardrobe_popup.popup_centered()
		player.can_move = false
	)
	wardrobe_popup.popup_hide.connect(func():
		player.can_move = true
	)


func _exit_tree() -> void:
	SavedData.save_data()
