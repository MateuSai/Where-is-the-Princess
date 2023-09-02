extends Node2D

@onready var player: Player = get_node("Player")
@onready var start_interact_area: InteractArea = get_node("StartInteractArea")
@onready var wardrobe_interact_area: InteractArea = get_node("Wardrobe/WardrobeInteractArea")
@onready var settings_interact_area: InteractArea = $Settings/SettingsInteractArea
#@onready var mods_interact_area: InteractArea = $Mods/ModsInteractArea

@onready var seed_interact_area: InteractArea = $SeedSelectorSprite/InteractArea
@onready var seed_popup: Popup = get_node("SeedPopup")

@onready var exit_interact_area: InteractArea = get_node("ExitInteractArea")
@onready var wardrobe_popup: Popup = get_node("WardrobePopup")


func _ready() -> void:
	player.set_armor(load(SavedData.data.equipped_armor).new())

	start_interact_area.player_interacted.connect(func():
		var seed_spin_box: SpinBox = seed_popup.get_node("MarginContainer/SpinBox")
		var run_seed: int
		if seed_spin_box.value == -1:
			run_seed = randi()
		else:
			run_seed = int(seed_spin_box.value)
		#run_seed = 1991508849
		print("Seed: " + str(run_seed) + "\n")
		seed(run_seed)
		Globals.run_seed = run_seed
		SceneTransistor.start_transition_to("res://Game.tscn")
	)

	settings_interact_area.player_interacted.connect(func():
		Settings.popup_centered()
		player.can_move = false
	)
	Settings.popup_hide.connect(func():
		player.can_move = true
	)

#	mods_interact_area.player_interacted.connect(func():
#		var mod_menu: ModMenu = ModMenu.new()
#		add_child(mod_menu)
#		player.can_move = false
#		mod_menu.popup_hide.connect(func():
#			player.can_move = true
#		)
#	)

	exit_interact_area.player_interacted.connect(func():
		get_tree().quit()
	)

	seed_interact_area.player_interacted.connect(func():
		seed_popup.popup_centered()
		player.can_move = false
	)
	seed_popup.popup_hide.connect(func():
		player.can_move = true
	)

	wardrobe_interact_area.player_interacted.connect(func():
		wardrobe_popup.popup_centered()
		player.can_move = false
	)
	wardrobe_popup.popup_hide.connect(func():
		player.can_move = true
	)

	if not SavedData.data.shop_unlocked:
		$BaseCampShop.queue_free()


func _exit_tree() -> void:
	SavedData.save_data()
