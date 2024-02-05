class_name BaseCamp extends DungeonRoom

@onready var game: Game = get_parent().get_parent()

@onready var wardrobe_interact_area: InteractArea = get_node("Wardrobe/WardrobeInteractArea")
@onready var settings_interact_area: InteractArea = $Settings/SettingsInteractArea
#@onready var mods_interact_area: InteractArea = $Mods/ModsInteractArea

@onready var seed_interact_area: InteractArea = $SeedSelectorSprite/InteractArea
@onready var seed_popup: Popup = get_node("SeedPopup")

@onready var wardrobe_popup: Popup = get_node("WardrobePopup")


func _ready() -> void:
	super()

	randomize()
	_set_seed()

	game.player_added.connect(func() -> void:
		var armor_script: GDScript = load(SavedData.data.equipped_armor)
		Globals.player.set_armor(armor_script.new() as Armor)

		settings_interact_area.player_interacted.connect(func() -> void:
			Settings.popup_centered()
			Globals.player.can_move = false
		)
		Settings.popup_hide.connect(func() -> void:
			Globals.player.can_move = true
		)


	#	mods_interact_area.player_interacted.connect(func():
	#		var mod_menu: ModMenu = ModMenu.new()
	#		add_child(mod_menu)
	#		player.can_move = false
	#		mod_menu.popup_hide.connect(func():
	#			player.can_move = true
	#		)
	#	)

		seed_interact_area.player_interacted.connect(func() -> void:
			seed_popup.popup_centered()
			Globals.player.can_move = false
		)
		seed_popup.popup_hide.connect(func() -> void:
			Globals.player.can_move = true
			_set_seed()
		)

		wardrobe_interact_area.player_interacted.connect(func() -> void:
			wardrobe_popup.popup_centered()
			($WardrobeOpenSound as AudioStreamPlayer).play()
			Globals.player.can_move = false
		)
		wardrobe_popup.popup_hide.connect(func() -> void:
			Globals.player.can_move = true
		)
	)


func _exit_tree() -> void:
	super()

	SavedData.save_data()


func _set_seed() -> void:
	var seed_spin_box: SpinBox = seed_popup.get_node("MarginContainer/SpinBox")
	var run_seed: int
	if seed_spin_box.value == -1:
		run_seed = randi() % 100000000 # Eight digit number
	else:
		run_seed = int(seed_spin_box.value)
	run_seed = 82172250
	print("Changed seed to  " + str(run_seed) + "\n")
	#seed(run_seed)
	SavedData.run_stats.run_seed = run_seed
