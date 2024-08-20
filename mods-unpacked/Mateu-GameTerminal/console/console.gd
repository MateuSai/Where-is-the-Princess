class_name Console extends LineEdit

static var last_command: String = ""

@onready var ui: GameUI = get_tree().current_scene.get_node("UI")

@onready var debug_info: VBoxContainer = $"../DebugInfo"

func _ready() -> void:
	draw.connect(func() -> void:
		get_tree().paused=true
		#show()
		#set_process_input(true)
		#get_tree().current_scene.get_node("%UI").is_external_thing_opened = true
		grab_focus()
	)
	hidden.connect(func() -> void:
		get_tree().paused=false
		#hide()
		#set_process_input(false)
		ui.set_process_unhandled_input(true)
		#get_tree().current_scene.get_node("%UI").is_external_thing_opened = false
	)
	hide()
	#set_process_input(false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_toggle_terminal") and debug_info.visible:
		show()
		ui.set_process_unhandled_input(false)
	elif (event.is_action_pressed("ui_toggle_terminal") or event.is_action_pressed("ui_cancel")) and visible:
		hide()
		ui.set_process_unhandled_input(true)
		get_viewport().set_input_as_handled()
	elif visible:
		if event is InputEventKey:
			# We want to ignore the inputs used to close the terminal. The closing of the terminal is handled on DebugUI
			#if (event.is_action_pressed("ui_toggle_terminal") or event.is_action_pressed("ui_cancel")):
				#return

			# si el jugador presiona la flecha de arriba, cargamos la ultima comanda que ejecutamos, solo si esta no es nula
			if event.is_pressed() and (event as InputEventKey).keycode == KEY_UP:
				if last_command.length() > 0:
					get_viewport().set_input_as_handled() # para que el caret no vuelva a la posición inicial
					text = last_command
					caret_column = last_command.length()
			elif event.is_pressed() and (event as InputEventKey).keycode in [KEY_ENTER, KEY_KP_ENTER]:
				# solo procesamos la comanda si no esta vacia
				if text.strip_edges().length() > 0:
					_process_command(text)
					last_command = text

				text = ""

func _process_command(command: String) -> void:
	# tiene que haber un nombre par de comillas
	if command.count("\"") % 2:
		printerr("Number of \" is not pair")
		return

	var splitted_command_by_quotation_marks: PackedStringArray = command.split("\"")
	for i: int in range(splitted_command_by_quotation_marks.size() - 1, -1, -1):
		if splitted_command_by_quotation_marks[i] in ["", " "]:
			splitted_command_by_quotation_marks.remove_at(i)
		# elemento que no esta entre comillas
		elif i % 2 == 0:
			# elimino espacios al inicio y al final
			splitted_command_by_quotation_marks[i] = splitted_command_by_quotation_marks[i].strip_edges()
			# si tiene espacios lo dividimos
			if splitted_command_by_quotation_marks[i].count(" "):
				var splitted_by_spaces: PackedStringArray = splitted_command_by_quotation_marks[i].split(" ")
				for j: int in range(splitted_by_spaces.size() - 1, -1, -1):
					# eliminamos los elementos vacios
					if splitted_by_spaces[i] in ["", " "]:
						splitted_by_spaces.remove_at(j)
					else:
						splitted_command_by_quotation_marks.insert(i + 1, splitted_by_spaces[j])
				# eliminamos el elemento que acabamos de dividir en subelementos
				splitted_command_by_quotation_marks.remove_at(i)

	print(splitted_command_by_quotation_marks)

	var splitted_command: PackedStringArray = splitted_command_by_quotation_marks

	match splitted_command[0].to_lower():
		"set":
			if splitted_command.size() > 1: # tiene otro argumento
				match splitted_command[1].to_lower():
					"hp":
						if splitted_command.size() > 2:
							_set_player_hp(splitted_command[2])
						else:
							printerr("You must specify the new hp")
					"armor":
						if splitted_command.size() > 2:
							_set_armor(splitted_command[2])
						else:
							printerr("You must specify the armor path")
					"armor condition", "ac", "armor cond":
						if splitted_command.size() > 2:
							_set_armor_condition(splitted_command[2])
						else:
							printerr("You must specify the new condition")
					"current weapon condition", "weapon condition", "wc", "weapon cond":
						if splitted_command.size() > 2:
							_set_current_weapon_condition(splitted_command[2])
						else:
							printerr("You must specify the new condition")
					"worldcol":
						if splitted_command.size() > 2:
							_set_player_worldcol(splitted_command[2])
						else:
							printerr("You must specify the new value of worldcol")
					"invincible", "in":
						if splitted_command.size() > 2:
							_set_player_invincible(splitted_command[2])
						else:
							printerr("You must specify the new value of invincible")
					"time scale", "ts":
						if splitted_command.size() > 2:
							_set_time_scale(splitted_command[2])
						else:
							printerr("You must specify the new value of time scale")
					"coins":
						if splitted_command.size() > 2:
							_set_coins(splitted_command[2])
						else:
							printerr("You must specify the new value of the coins")
					"souls":
						if splitted_command.size() > 2:
							_set_souls(splitted_command[2])
						else:
							printerr("You must specify the new value of the current weapon souls")
					"dark souls", "ds":
						if splitted_command.size() > 2:
							_set_dark_souls(splitted_command[2])
						else:
							printerr("You must specify the new value of the dark souls")
					"biome":
						if splitted_command.size() > 2:
							_set_biome(splitted_command[2])
						else:
							printerr("You must specify the new biome")
					"time":
						if splitted_command.size() > 2:
							_set_time(splitted_command[2])
						else:
							printerr("You must specify the new time")
					"player statistics", "ps":
						if splitted_command.size() > 2:
							if splitted_command.size() > 3:
								_set_player_statistics_property(splitted_command[2], splitted_command[3])
							else:
								printerr("You must specify the new value")
						else:
							printerr("You must specify the property to set")
					_:
						printerr("Invalid argument for set")
			else:
				printerr("Invalid number of arguments, you must specify what to set")
		"add":
			if splitted_command.size() > 1: # tiene otro argumento
				match splitted_command[1].to_lower():
					"status":
						if splitted_command.size() > 2:
							_add_status(splitted_command[2])
						else:
							printerr("You must specify a status")
					_:
						printerr("Invalid add option")
			else:
				printerr("Invalid number of arguments, you must specify what to add")
		"spawn":
			if splitted_command.size() > 1: # tiene otro argumento
				match splitted_command[1].to_lower():
					"weapon", "weap":
						if splitted_command.size() > 2:
							_spawn_weapon(splitted_command[2])
						else:
							printerr("You must specify a weapon path")
					"item":
						if splitted_command.size() > 2:
							_spawn_item(splitted_command[2])
						else:
							printerr("You must specify a item path")
					"enemy":
						if splitted_command.size() > 3:
							_spawn_enemy(splitted_command[2], splitted_command[3])
						elif splitted_command.size() > 2:
							_spawn_enemy(splitted_command[2])
						else:
							printerr("You must specify a enemy path")
					"chest":
						_spawn_chest()
					_:
						printerr("Command " + splitted_command[0] + " " + splitted_command[1] + " does not exist")
			else:
				printerr("Invalid number of arguments, you must specify what to spawn")
		"start":
			if splitted_command.size() > 1: # tiene otro argumento
				match splitted_command[1].to_lower():
					"dialogue", "dia":
						if splitted_command.size() > 2:
							_start_player_dialogue(splitted_command[2])
						else:
							printerr("You must specify the dialogue text")
					_:
						printerr("Command " + splitted_command[0] + " " + splitted_command[1] + " does not exist")
			else:
				printerr("Invalid number of arguments, you must specify what to spawn")
		"i'm fucking invincible":
			_set_player_invincible("t")
		"reload", "rel", "r":
			_reload()
		"save":
			_save()
		"clear":
			_clear_room()
		"react":
			if splitted_command.size() > 1: # tiene otro argumento
				_react(splitted_command[1])
			else:
				printerr("Invalid number of arguments, you must specify the reaction face")
		"test":
			if splitted_command.size() > 1: # tiene otro argumento
				match splitted_command[1]:
					"room":
						if splitted_command.size() > 2: # tiene otro argumento
							_test_room(splitted_command[2])
						else:
							_test_room()
					_:
						printerr("test has no " + splitted_command[1] + " option")
			else:
				printerr("test cannot be used by itself")
		"discover":
			if splitted_command.size() > 1: # tiene otro argumento
				match splitted_command[1]:
					"items":
						_discover_all_items()
					"armors":
						_discover_all_armors()
					_:
						printerr("discover has no " + splitted_command[1] + " option")
			else:
				printerr("discover cannot be used by itself")
		"print", "p":
			if splitted_command.size() > 1: # tiene otro argumento
				match splitted_command[1]:
					"orphans", "or":
						_print_orpahans()
					"room":
						_print_current_room_name()
					_:
						printerr("print has no " + splitted_command[1] + " option")
			else:
				printerr("print cannot be used by itself")
		"where am i", "where the fuck am i", "pr":
			_print_current_room_name()
		_:
			printerr("Invalid command")

func _set_player_hp(hp_string: String) -> void:
	if not hp_string.is_valid_float():
		printerr("Invalid value for player hp")
		return

	hide()
	Globals.player.life_component.last_damage_dealer_id = "console"
	Globals.player.life_component.hp = int(hp_string)
#	var new_hp: int = int(clamp(int(hp_string), 0.0, 100.0))
#	Globals.player.hp = new_hp

func _set_armor(armor_string: String) -> void:
	var armor_path: String

	if armor_string.is_absolute_path():
		if not FileAccess.file_exists(armor_string):
			printerr("Error: There is no file at " + armor_string)
			return
		armor_path = armor_string
	else:
		armor_path = Armor.id_to_path(armor_string)
		if armor_path.is_empty():
			printerr("Error: could not find armor with id " + armor_string)
			return

	var armor_script: GDScript = load(armor_path)
	if not armor_script:
		printerr("Error: There is no script at the specified path")
		return

	var script_instance: Object = armor_script.new()
	if not script_instance is Armor:
		printerr("Error: " + armor_path + " does not extend Armor")
		return

	Globals.player.set_armor(script_instance as Armor)

	if SavedData.run_stats.biome == "basecamp":
		SavedData.data.equipped_armor = (script_instance.get_script() as Script).get_path()

	hide()

func _set_armor_condition(condition_string: String) -> void:
	if not condition_string.is_valid_int():
		printerr("Invalid value for armor condition")
		return

	hide()
	Globals.player.armor.condition = int(condition_string)

func _set_current_weapon_condition(condition_string: String) -> void:
	if not condition_string.is_valid_int():
		printerr("Invalid value for weapon condition")
		return

	hide()
	Globals.player.weapons.current_weapon.stats.condition = int(condition_string)

func _set_player_worldcol(worldcol: String) -> void:
	if _get_bool_from_string(worldcol):
		hide()
		Globals.player.set_collision_mask_value(1, true)
	else:
		hide()
		Globals.player.set_collision_mask_value(1, false)

func _start_player_dialogue(dialogue_text: String) -> void:
	Globals.player.start_dialogue(dialogue_text)

	hide()

func _set_player_invincible(value: String) -> void:
	if _get_bool_from_string(value):
		hide()
		Globals.player.life_component.invincible = true
	else:
		hide()
		Globals.player.life_component.invincible = false

func _set_time_scale(time_scale_string: String) -> void:
	if not time_scale_string.is_valid_float():
		printerr("Invalid value for time scale")
		return

	hide()
	var new_time_scale: float = clamp(float(time_scale_string), 0.0, 10.0)
	Engine.time_scale = new_time_scale

func _set_coins(coins_string: String) -> void:
	if not coins_string.is_valid_int():
		push_error("Invalid value for coins")
		return

	hide()
	SavedData.run_stats.coins = coins_string.to_int()

func _set_souls(souls_string: String) -> void:
	if not souls_string.is_valid_float():
		push_error("Invalid value for weapon souls")
		return

	hide()
	Globals.player.weapons.current_weapon.stats.souls = int(souls_string)

func _set_dark_souls(souls_string: String) -> void:
	if not souls_string.is_valid_float():
		push_error("Invalid value for dark souls")
		return

	hide()
	SavedData.set_dark_souls(int(souls_string))

func _set_biome(biome: String) -> void:
	hide()

	Globals.exit_level(biome)

func _set_time(time_string: String) -> void:
	if not time_string.is_valid_float():
		printerr("the time specified must be a float")
		return

	DayNightSystem.time = time_string.to_float()

	hide()

func _set_player_statistics_property(property: String, new_value: String) -> void:
	var player_statistics: PlayerStatistics = SavedData.statistics.get_player_statistics()

	var player_statistics_property = player_statistics.get(property)
	if player_statistics_property == null:
		printerr("Invalid property")
		return

	if player_statistics_property is int:
		player_statistics.set(property, new_value.to_int())
	else:
		player_statistics.set(property, new_value)

	SavedData.statistics.save()

	hide()

func _get_bool_from_string(s: String) -> bool:
	if s in ["true", "t", "tr", "1"]:
		return true
	elif s in ["false", "f", "0"]:
		return false
	else:
		printerr("Can't convert string to bool, returning false")
		return false

func _add_status(status_string: String) -> void:
	match status_string:
		"ice":
			Globals.player.add_status_condition(StatusComponent.Status.ICE)
		"acid":
			Globals.player.add_status_condition(StatusComponent.Status.ACID)
		"fire":
			Globals.player.add_status_condition(StatusComponent.Status.FIRE)
		"lightning":
			Globals.player.add_status_condition(StatusComponent.Status.LIGHTNING)
		_:
			printerr("invalid stauts")
			return

	hide()

func _spawn_weapon(weapon_string: String) -> void:
	var weapon_path: String

	if weapon_string.is_absolute_path():
		var _path: String = weapon_string
		if not OS.has_feature("editor"):
			_path += ".remap"
		if FileAccess.file_exists(_path):
			weapon_path = weapon_string
		else:
			printerr("There is no weapon at path: " + weapon_string)
			return
	else:
		weapon_path = Weapon.get_weapon_path(weapon_string)
		if weapon_path == "":
			printerr("Couldn't get path to " + weapon_string)
			return

	hide()
	var weapon: Weapon = (load(weapon_path) as PackedScene).instantiate()
	weapon.position = Globals.player.position + Vector2.RIGHT * 16
	#weapon.on_floor = true
	get_tree().current_scene.add_child(weapon)

func _spawn_item(item_string: String) -> void:
	if Globals.player.current_room == null:
		printerr("You must be inside a room to spawn items")
		return

	var item_script: GDScript = load(item_string)
	if item_script == null:
		printerr("There is no item script at: " + item_string)
		return

	var item: Item = item_script.new()
	var item_on_floor: ItemOnFloor = (load("res://items/item_on_floor.tscn") as PackedScene).instantiate()
	Globals.player.current_room.add_item_on_floor(item_on_floor, (Globals.player.position + Vector2.RIGHT * 16) - Globals.player.current_room.position)
	#item_on_floor.position = Globals.player.position + Vector2.RIGHT * 16
	item_on_floor.initialize(item)
	#get_tree().current_scene.add_child(item_on_floor)
	item_on_floor.enable_pick_up()

	hide()

func _spawn_enemy(enemy_string: String, amount_strign: String="1") -> void:
	var enemy: Enemy
	var amount: int

	if not amount_strign.is_valid_int():
		push_error("Error: Invalid value for enemy amount")
		return

	amount = int(amount_strign)
	if amount < 1:
		printerr("Error: amount must be 1 or greater")
		return

	if enemy_string.is_absolute_path():
		var enemy_scene: PackedScene = load(enemy_string)
		if not enemy_scene:
			printerr("Error: invalid scene path")
			return
		enemy = enemy_scene.instantiate()
	else:
		for i: int in amount:
			var enemy_scene: PackedScene = Globals.get_enemy_scene(enemy_string)
			if enemy_scene:
				enemy = enemy_scene.instantiate()
				(get_tree().current_scene.get_node("Rooms") as Rooms).rooms[0].add_child(enemy)
				enemy.global_position = Globals.player.position + Vector2.RIGHT * 16 + Vector2(randf_range( - 8, 8), randf_range( - 8, 8))
			else:
				printerr("Error: no registered enemy with this name")
				return

	hide()

func _spawn_chest() -> void:
	var chest: Chest = preload ("res://Rooms/Chest.tscn").instantiate()
	(get_tree().current_scene.get_node("Rooms") as Rooms).rooms[0].add_child(chest)
	chest.global_position = Globals.player.position + Vector2.RIGHT * 16

	hide()

func _reload() -> void:
	print_debug("Reloading scene...")

	get_tree().paused = false
	get_tree().reload_current_scene()

	print_debug("Scene reloaded")

func _save() -> void:
	SavedData.save_run_stats()

	hide()

func _clear_room() -> void:
	if Globals.player.current_room == null:
		printerr("You are on a corridor")
		return

	Globals.player.current_room.kill_all_enemies()

	hide()

func _react(face_string: String) -> void:
	if not face_string.is_valid_int():
		printerr("You must indicate the reaction face using his index")
		return

	Globals.player.react(int(face_string))

	hide()

func _test_room(path: String="res://Rooms/test_room.tscn") -> void:
	if not FileAccess.file_exists(path):
		printerr("There is no file at " + path)
		return

	var biome_conf: BiomeConf = BiomeConf.new()
	var level: BiomeConf.Level = BiomeConf.Level.new()
	level.overwrite_start_rooms = ["res://Rooms/Biomes/forest/Start/ForestSpawnRoom0.tscn"]
	level.num_combat_rooms = 1
	level.overwrite_combat_rooms = [path]
	level.overwrite_weapons_on_floor = []
	biome_conf.levels.push_back(level)

	SavedData._change_biome_by_conf(biome_conf)

	SceneTransistor.start_transition_to("res://Game.tscn")

	hide()

func _discover_all_items() -> void:
	for item_path: String in SavedData.data.AVAILABLE_PERMANENT_ITEMS_FROM_START:
		SavedData.discover_permanent_item_if_not_already(item_path)

	for item_path: String in SavedData.data.AVAILABLE_TEMPORAL_ITEMS_FROM_START:
		SavedData.discover_temporal_item_if_not_already(item_path)

	hide()

func _discover_all_armors() -> void:
	for armor_path: String in Data.AVAILABLE_ARMORS_FROM_START:
		SavedData.discover_armor_if_not_already(armor_path)

	hide()

func _print_orpahans() -> void:
	LineEdit.print_orphan_nodes()

	hide()

func _print_current_room_name() -> void:
	if Globals.player.current_room:
		print("You are on " + Globals.player.current_room.name)
	else:
		print("You are not in any room")

	hide()
