extends Node2D

@onready var player: Player = get_node("Player")
@onready var start_interact_area: InteractArea = get_node("StartInteractArea")
@onready var wardrobe_interact_area: InteractArea = get_node("Wardrobe/WardrobeInteractArea")
@onready var wardrobe_popup: Popup = get_node("WardrobePopup")


func _ready() -> void:
	start_interact_area.player_interacted.connect(func():
		SceneTransistor.start_transition_to("res://Game.tscn")
	)

	wardrobe_interact_area.player_interacted.connect(func():
		wardrobe_popup.popup_centered()
		player.can_move = false
	)
	wardrobe_popup.popup_hide.connect(func():
		player.can_move = true
	)
