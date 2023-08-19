extends LineEdit

var last_command: String = ""


func _ready() -> void:
	draw.connect(func():
		get_tree().paused = true
		#show()
		set_process_input(true)
		#get_tree().current_scene.get_node("%UI").is_external_thing_opened = true
		grab_focus()
	)
	hidden.connect(func():
		get_tree().paused = false
		#hide()
		set_process_input(false)
		#get_tree().current_scene.get_node("%UI").is_external_thing_opened = false
	)
	hide()
	set_process_input(false)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		# si el jugador presiona la flecha de arriba, cargamos la ultima comanda que ejecutamos, solo si esta no es nula
		if event.is_pressed() and event.keycode == KEY_UP:
			if last_command.length() > 0:
				get_viewport().set_input_as_handled() # para que el caret no vuelva a la posición inicial
				text = last_command
				caret_column = last_command.length()
		elif event.is_pressed() and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
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

	var splitted_command_by_quotation_marks: Array = command.split("\"")
	for i in range(splitted_command_by_quotation_marks.size() - 1, -1, -1):
		if splitted_command_by_quotation_marks[i] in ["", " "]:
			splitted_command_by_quotation_marks.remove_at(i)
		# elemento que no esta entre comillas
		elif i % 2 == 0:
			# elimino espacios al inicio y al final
			splitted_command_by_quotation_marks[i] = splitted_command_by_quotation_marks[i].strip_edges()
			# si tiene espacios lo dividimos
			if splitted_command_by_quotation_marks[i].count(" "):
				var splitted_by_spaces: PackedStringArray = splitted_command_by_quotation_marks[i].split(" ")
				for j in range(splitted_by_spaces.size() - 1, -1, -1):
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
							push_error("You must specify the new hp")
					"worldcol":
						if splitted_command.size() > 2:
							_set_player_worldcol(splitted_command[2])
						else:
							push_error("You must specify the new value of worldcol")
					"invincible", "in":
						if splitted_command.size() > 2:
							_set_player_invincible(splitted_command[2])
						else:
							push_error("You must specify the new value of invincible")
			else:
				push_error("Invalid number of arguments, you must specify what to set")
		"spawn":
			if splitted_command.size() > 1: # tiene otro argumento
				match splitted_command[1].to_lower():
					"weapon", "weap":
						if splitted_command.size() > 2:
							_spawn_weapon(splitted_command[2])
						else:
							push_error("You must specify a weapon path")
			else:
				push_error("Invalid number of arguments, you must specify what to spawn")
#			if splitted_command.size() > 1: # tiene otro argumento
#				match splitted_command[1]:
#					"weapon", "weap":
#						if splitted_command.size() == 3: # tiene otro argumento
#							_spawn_weapon(splitted_command[2])
#						elif splitted_command.size() > 3: # tiene un cuarto arguemnto (el tier)
#							_spawn_weapon(splitted_command[2], splitted_command[3])
#						else:
#							printerr("Invalid command: you must specify a weapon")
#					"throw", "throwable":
#						if splitted_command.size() > 2: # tiene otro argumento
#							if splitted_command.size() > 3: # tiene dos argumentos más
#								_spawn_throwable(splitted_command[2], splitted_command[3])
#							else:
#								_spawn_throwable(splitted_command[2])
#						else:
#							printerr("Invalid command: you must specify a throwable weapon")
#					"ammo":
#						if splitted_command.size() > 2: # tiene otro argumento
#							_spawn_ammo(splitted_command[2])
#						else:
#							printerr("Invalid command: you must specify the type of ammo")
#					"armor":
#						if splitted_command.size() > 2: # tiene otro argumento
#							_spawn_armor(splitted_command[2])
#						else:
#							printerr("Invalid command: you must specify the armor name")
#					"enemy":
#						if splitted_command.size() > 2: # tiene otro argumento
#							if splitted_command.size() > 3: # tiene dos argumentos más
#								_spawn_enemy(splitted_command[2], splitted_command[3])
#							else:
#								_spawn_enemy(splitted_command[2])
#						else:
#							printerr("Invalid command: you must specify the enemy type")
#					"resource", "res":
#						if splitted_command.size() > 3: # tiene dos argumentos más
#							if not splitted_command[3].is_valid_integer() or int(splitted_command[3]) <= 0:
#								printerr("amount must be an int and greater than 0!")
#							else:
#								_spawn_resource(splitted_command[2], int(splitted_command[3]))
#						elif splitted_command.size() > 2: # tiene otro argumento
#							_spawn_resource(splitted_command[2])
#						else:
#							printerr("Invalid command: you must specify the resource type")


func _set_player_hp(hp_string: String) -> void:
	if not hp_string.is_valid_float():
		push_error("Invalid value for player hp")
		return

	hide()
	Globals.player.life_component.hp = int(hp_string)
#	var new_hp: int = int(clamp(int(hp_string), 0.0, 100.0))
#	Globals.player.hp = new_hp


func _set_player_worldcol(worldcol: String) -> void:
	if _get_bool_from_string(worldcol):
		hide()
		Globals.player.set_collision_mask_value(1, true)
	else:
		hide()
		Globals.player.set_collision_mask_value(1, false)


func _set_player_invincible(value: String) -> void:
	if _get_bool_from_string(value):
		hide()
		Globals.player.life_component.invincible = true
	else:
		hide()
		Globals.player.life_component.invincible = false


func _get_bool_from_string(s: String) -> bool:
	if s in ["true", "t", "tr", "1"]:
		return true
	elif s in ["false", "f", "0"]:
		return false
	else:
		printerr("Can't convert string to bool, returning false")
		return false


func _spawn_weapon(weapon_string: String) -> void:
	var weapon: Weapon = load(weapon_string).instantiate()
	weapon.position = Globals.player.position + Vector2.RIGHT * 16
	weapon.on_floor = true
	get_tree().current_scene.add_child(weapon)
