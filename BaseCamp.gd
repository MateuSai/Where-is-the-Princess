class_name BaseCamp extends Node2D

@onready var player: Player = get_node("Player")
@onready var wardrobe_interact_area: InteractArea = get_node("Wardrobe/WardrobeInteractArea")
@onready var settings_interact_area: InteractArea = $Settings/SettingsInteractArea
#@onready var mods_interact_area: InteractArea = $Mods/ModsInteractArea

@onready var seed_interact_area: InteractArea = $SeedSelectorSprite/InteractArea
@onready var seed_popup: Popup = get_node("SeedPopup")

@onready var exit_interact_area: InteractArea = get_node("ExitInteractArea")
@onready var wardrobe_popup: Popup = get_node("WardrobePopup")


func _ready() -> void:
	var armor_script: GDScript = load(SavedData.data.equipped_armor)
	player.set_armor(armor_script.new() as Armor)

	settings_interact_area.player_interacted.connect(func() -> void:
		Settings.popup_centered()
		player.can_move = false
	)
	Settings.popup_hide.connect(func() -> void:
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

	exit_interact_area.player_interacted.connect(func() -> void:
		get_tree().quit()
	)

	seed_interact_area.player_interacted.connect(func() -> void:
		seed_popup.popup_centered()
		player.can_move = false
	)
	seed_popup.popup_hide.connect(func() -> void:
		player.can_move = true
	)

	wardrobe_interact_area.player_interacted.connect(func() -> void:
		wardrobe_popup.popup_centered()
		($WardrobeOpenSound as AudioStreamPlayer).play()
		player.can_move = false
	)
	wardrobe_popup.popup_hide.connect(func() -> void:
		player.can_move = true
	)


func _exit_tree() -> void:
	SavedData.save_data()


func start_game() -> void:
	var seed_spin_box: SpinBox = seed_popup.get_node("MarginContainer/SpinBox")
	var run_seed: int
	if seed_spin_box.value == -1:
		run_seed = randi()
	else:
		run_seed = int(seed_spin_box.value)
	#run_seed = 2838917277
	print("Seed: " + str(run_seed) + "\n")
	seed(run_seed)
	Globals.run_seed = run_seed
	SceneTransistor.start_transition_to("res://Game.tscn")
