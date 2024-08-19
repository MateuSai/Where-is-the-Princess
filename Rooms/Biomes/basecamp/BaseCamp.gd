class_name BaseCamp extends DungeonRoom

@onready var game: Game = get_parent().get_parent()

@onready var wardrobe_interact_area: InteractArea = get_node("Wardrobe/WardrobeInteractArea")
@onready var settings_interact_area: InteractArea = $Settings/SettingsInteractArea
#@onready var mods_interact_area: InteractArea = $Mods/ModsInteractArea

@onready var seed_interact_area: InteractArea = $SeedSelectorSprite/InteractArea
@onready var seed_popup: Popup = get_node("SeedPopup")

@onready var wardrobe_popup: Popup = get_node("WardrobePopup")

@onready var wake_up_dialogue_timer: Timer = $WakeUpDialogueTimer

func _init() -> void:
	randomize()

func _ready() -> void:
	super()

	# Moved this shit to rooms.gd
	#if Globals.debug and scene_file_path == "res://Rooms/Biomes/basecamp/BaseCamp.tscn":
		#var debug_basecamp: DungeonRoom = load("res://Rooms/Biomes/basecamp/DebugBaseCamp.tscn").instantiate()
		#debug_basecamp.position = position
		#name += "ssdfdsfdfsf"
		#debug_basecamp.name = "BaseCamp_0"
		#rooms.add_child(debug_basecamp)
		#rooms.start_room = debug_basecamp
		#rooms.rooms = [debug_basecamp]
		#queue_free()

	_set_seed()

	game.player_added.connect(func() -> void:
		var armor_script: GDScript=load(SavedData.data.equipped_armor)
		Globals.player.set_armor(armor_script.new() as Armor)

		#settings_interact_area.player_interacted.connect(func() -> void:
		#	Settings.popup_centered()
		#	Globals.player.can_move=false
		#)
		#Settings.popup_hide.connect(func() -> void:
		#	Globals.player.can_move=true
		#)

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
			Globals.player.can_move=false
		)
		seed_popup.popup_hide.connect(func() -> void:
			Globals.player.can_move=true
			_set_seed()
		)

		var random_start_weapon_path: String=SavedData.get_random_available_weapon_path()
		var random_start_weapon: Weapon=load(random_start_weapon_path).instantiate()
		add_child(random_start_weapon)
		random_start_weapon._on_PlayerDetector_body_entered(Globals.player)

		wardrobe_interact_area.player_interacted.connect(func() -> void:
			wardrobe_popup.popup_centered()
			($WardrobeOpenSound as AudioStreamPlayer).play()
			Globals.player.can_move=false
		)
		wardrobe_popup.popup_hide.connect(func() -> void:
			Globals.player.can_move=true
		)

		wake_up_dialogue_timer.timeout.connect(func() -> void:
			var dialogue_key: String="PLAYER_WAKE_UP_DIALOGUE_" + str(SavedData.statistics.get_player_statistics().times_killed)
			#print(tr(dialogue_key))
			if dialogue_key != tr(dialogue_key): # Dialogue available
				Globals.player.start_dialogue(dialogue_key)
			elif not SavedData.last_time_killed_by.is_empty():
				var options: PackedStringArray=["PLAYER_WAKE_UP_DIALOGUE_KILLED_BY_ENEMY_1"]
				Globals.player.start_dialogue(tr(options[randi() % options.size()]) % tr(SavedData.last_time_killed_by.to_upper()))
		)
		wake_up_dialogue_timer.start()
	)

func _exit_tree() -> void:
	super()

	SavedData.data.save()

func _set_seed() -> void:
	var seed_line_edit: LineEdit = seed_popup.get_node("MarginContainer/LineEdit")
	var run_seed: int
	if seed_line_edit.text.is_empty():
		run_seed = randi() % 100000000 # Eight digit number
	else:
		run_seed = int(seed_line_edit.text)
	#run_seed = 61637520
	print("Changed seed to  " + str(run_seed) + "\n")
	#seed(run_seed)
	SavedData.run_stats.run_seed = run_seed
