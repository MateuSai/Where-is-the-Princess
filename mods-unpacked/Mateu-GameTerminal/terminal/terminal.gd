class_name Terminal extends LineEdit

static var last_command: String = ""

@onready var ui: GameUI = get_tree().current_scene.get_node("UI")

@onready var debug_info: VBoxContainer = $"../DebugInfo"


func _ready() -> void:
	draw.connect(func() -> void:
		get_tree().paused = true
		#show()
		#set_process_input(true)
		#get_tree().current_scene.get_node("%UI").is_external_thing_opened = true
		grab_focus()
	)
	hidden.connect(func() -> void:
		get_tree().paused = false
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
						splitted_command_by_quotation_marks.insert(i+1, splitted_by_spaces[j])
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
					_:
						printerr("Invalid argument for set")
			else:
				printerr("Invalid number of arguments, you must specify what to set")
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
							printerr("Invalid number of arguments, you must specify the room path")
					_:
						printerr("test has no " + splitted_command[1] + " option")
			else:
				printerr("test cannot be used by itself")
		_:
			printerr("Invalid command")


func _set_player_hp(hp_string: String) -> void:
	if not hp_string.is_valid_float():
		printerr("Invalid value for player hp")
		return

	hide()
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


func _get_bool_from_string(s: String) -> bool:
	if s in ["true", "t", "tr", "1"]:
		return true
	elif s in ["false", "f", "0"]:
		return false
	else:
		printerr("Can't convert string to bool, returning false")
		return false


func _spawn_weapon(weapon_string: String) -> void:
	var weapon_path: String

	if weapon_string.is_absolute_path():
		if FileAccess.file_exists(weapon_string):
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
	weapon.on_floor = true
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


func _spawn_enemy(enemy_string: String, amount_strign: String = "1") -> void:
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
				enemy.global_position = Globals.player.position + Vector2.RIGHT * 16 + Vector2(randf_range(-8, 8), randf_range(-8, 8))
			else:
				printerr("Error: no registered enemy with this name")
				return

	hide()


func _spawn_chest() -> void:
	var chest: Chest = preload("res://Rooms/Chest.tscn").instantiate()
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

	for child: Node in Globals.player.current_room.get_children():
		if child is Enemy:
			child.life_component.take_damage(2000, Vector2.ZERO, 0, null)

	hide()


func _react(face_string: String) -> void:
	if not face_string.is_valid_int():
		printerr("You must indicate the reaction face using his index")
		return

	Globals.player.react(int(face_string))

	hide()


func _test_room(path: String) -> void:
	if not FileAccess.file_exists(path):
		printerr("There is no file at " + path)
		return

	RoomTest.room_path = path
	SceneTransistor.start_transition_to("res://Rooms/room_test.tscn")

	hide()
