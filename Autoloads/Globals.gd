extends Node

signal room_closed()
signal room_cleared()

signal pause_menu_opened()
signal pause_menu_closed()

signal character_received_damage(character: Node2D, damage_dealer: Node)

var player: Player = null

var global_stats: GlobalStats = GlobalStats.new()

var debug: bool = false

var app_id: int

var ENEMIES: Dictionary = {}

const INPUT_IMAGE_RECTS: Dictionary = {
	w = Rect2(288, 32, 16, 16),
	t = Rect2(336, 32, 16, 16),
	y = Rect2(252, 32, 16, 16),
	u = Rect2(368, 32, 16, 16),
	i = Rect2(384, 32, 16, 16),
	p = Rect2(416, 32, 16, 16),
	a = Rect2(288, 48, 16, 16),
	s = Rect2(304, 48, 16, 16),
	d = Rect2(320, 48, 16, 16),
	f = Rect2(336, 48, 16, 16),
	g = Rect2(352, 48, 16, 16),
	k = Rect2(400, 48, 16, 16),
	l = Rect2(416, 48, 16, 16),
	#key_ñ = Rect2(416, 48, 16, 16),
	"1" = Rect2(272, 16, 16, 16),
	"2" = Rect2(288, 16, 16, 16),
	"3" = Rect2(304, 16, 16, 16),
	"4" = Rect2(320, 16, 16, 16),
	"5" = Rect2(336, 16, 16, 16),
	"6" = Rect2(352, 16, 16, 16),
	"7" = Rect2(368, 16, 16, 16),
	"8" = Rect2(384, 16, 16, 16),
	"9" = Rect2(400, 16, 16, 16),
	"0" = Rect2(416, 16, 16, 16),
	#de aca para arriba hay que ordenarlas
	#ahora cómo podriamos poner números o comas, o teclas como ´+{-.,
	q = Rect2(272, 32, 16, 16),
	e = Rect2(304, 32, 16, 16),
	h = Rect2(368, 48, 16, 16),
	o = Rect2(400, 32, 16, 16),
	j = Rect2(384, 48, 16, 16),
	r = Rect2(320, 32, 16, 16),
	m = Rect2(400, 64, 16, 16),
	n = Rect2(384, 64, 16, 16),
	b = Rect2(368, 64, 16, 16),
	v = Rect2(352, 64, 16, 16),
	c = Rect2(336, 64, 16, 16),
	x = Rect2(320, 64, 16, 16),
	z = Rect2(304, 64, 16, 16),
	less = Rect2(416, 64, 16, 16),
	more = Rect2(432, 64, 16, 16),
	comma = Rect2(432, 96, 16, 16),

	tab = Rect2(304, 80, 23, 16),
	backspace = Rect2(512, 16, 32, 16),
	space = Rect2(496, 96, 48, 16),
	shift = Rect2(272, 112, 32, 16),
	control = Rect2(272, 96, 28, 16),
	alt = Rect2(272, 80, 28, 16),
	home = Rect2(336, 96, 28, 16),
	end = Rect2(368, 80, 25, 16),
	escape = Rect2(272, 0, 16, 16), # deberiamos evitar que el jugador seleccione esta tecla en el mapeo de teclas. La he añadido para usarla en las cinematicas

	left_mouse_button = Rect2(144, 32, 16, 16),
	right_mouse_button = Rect2(160, 32, 16, 16),
	middle_mouse_button = Rect2(176, 32, 16, 16),
	mouse_wheel_down = Rect2(208, 32, 16, 16),
	mouse_wheel_up = Rect2(192, 32, 16, 16),

	# JOYPAD
	xbox_joypad_button_0 = Rect2(208, 16, 16, 16), # xbox A
	xbox_joypad_button_1 = Rect2(224, 16, 16, 16), # xbox B
	xbox_joypad_button_2 = Rect2(240, 16, 16, 16), # xbox X
	xbox_joypad_button_3 = Rect2(256, 16, 16, 16), # xbox Y
	xbox_joypad_button_4 = Rect2(112, 288, 16, 16), # xbox LB
	xbox_joypad_button_5 = Rect2(128, 288, 16, 16), # xbox RB
	xbox_joypad_button_6 = Rect2(144, 288, 16, 16), # xbox LT
	xbox_joypad_button_7 = Rect2(160, 288, 16, 16), # xbox RT
	xbox_joypad_button_8 = Rect2(256, 96, 16, 16), # xbox L3
	xbox_joypad_button_9 = Rect2(256, 128, 16, 16), # xbox R3
	xbox_joypad_button_10 = Rect2(64, 288, 16, 16), # xbox select
	xbox_joypad_button_11 = Rect2(80, 288, 16, 16), # xbox start
	xbox_joypad_button_12 = Rect2(16, 16, 16, 16), # xbox d-pad up
	xbox_joypad_button_13 = Rect2(48, 16, 16, 16), # xbox d-pad down
	xbox_joypad_button_14 = Rect2(64, 16, 16, 16), # xbox d-pad left
	xbox_joypad_button_15 = Rect2(32, 16, 16, 16), # xbox d-pad right
	xbox_joypad_button_16 = Rect2(240, 320, 16, 16), # xbox button that emits light

	ps_joypad_button_0 = Rect2(368, 256, 16, 16), # ps X
	ps_joypad_button_1 = Rect2(304, 256, 16, 16), # ps circle
	ps_joypad_button_2 = Rect2(336, 256, 16, 16), # ps square
	ps_joypad_button_3 = Rect2(272, 256, 16, 16), # ps triangle
	ps_joypad_button_4 = Rect2(304, 288, 16, 16), # ps L1
	ps_joypad_button_5 = Rect2(320, 288, 16, 16), # ps R1
	ps_joypad_button_6 = Rect2(336, 288, 16, 16), # ps L2
	ps_joypad_button_7 = Rect2(352, 288, 16, 16), # ps R2
	ps_joypad_button_8 = Rect2(256, 96, 16, 16), # ps L3
	ps_joypad_button_9 = Rect2(256, 128, 16, 16), # ps R3
	ps_joypad_button_10 = Rect2(288, 320, 16, 16), # ps share
	ps_joypad_button_11 = Rect2(304, 320, 16, 16), # ps options
	ps_joypad_button_12 = Rect2(16, 112, 16, 16), # ps d-pad up
	ps_joypad_button_13 = Rect2(48, 112, 16, 16), # ps d-pad down
	ps_joypad_button_14 = Rect2(64, 112, 16, 16), # ps d-pad left
	ps_joypad_button_15 = Rect2(32, 112, 16, 16), # ps d-pad right
	ps_joypad_button_16 = Rect2(352, 320, 16, 16), # ps DualShock (WTF is a dualshock?)
}

var mode: int = Mode.MOUSE
enum Mode {
	MOUSE,
	CONTROLLER,
}
signal mode_changed(new_mode: Mode)
var controller_device: int
var controller_type: String
const CONTROLLER_TYPES: Dictionary = {
	PS = "ps",
	XBOX = "xbox",
}

enum Platform {
	STEAM,
	OTHER,
}
var platform: Platform

func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	if OS.has_feature("steam"): # and Steam.isSteamRunning():
		assert(Engine.has_singleton("Steam"))
		platform = Platform.STEAM
		Steam.steamInit()
		app_id = Steam.getAppID()
	else:
		platform = Platform.OTHER
	print("Platform detected: " + Platform.keys()[platform])

func _ready() -> void:
	debug = OS.get_cmdline_user_args().has("--debug")

	var enemies_folder: DirAccess = DirAccess.open(Enemy.ENEMIES_FOLDER_PATH)
	assert(enemies_folder != null)
	for enemy_folder: String in enemies_folder.get_directories():
		ENEMIES[enemy_folder.to_snake_case()] = Enemy.get_path_and_info(enemy_folder, enemies_folder)

	SceneTransistor.scene_changed.connect(_on_scene_changed)

	# To save key tiles as separate images
	#_save_key_tiles_as_separate_images()

	#_duplicate_item_icons_with_red_outline()

	Log.debug(IncreaseTimeBetweenAcidDamages.new(0.5).get_description())
	Log.debug(AntiAcidRingCursed.new().get_effects_description())
	Log.debug(ProjectileOrbCursed.new().get_effects_description())

	#print(ENEMIES)

func _save_key_tiles_as_separate_images() -> void:
	for key_id: String in INPUT_IMAGE_RECTS.keys():
		var atlas_texture: AtlasTexture = AtlasTexture.new()
		atlas_texture.atlas = load("res://Art/kenney_input-prompts-pixel-16/Tilemap/tilemap_packed.png")
		atlas_texture.region = KeyIcon.get_key_region(key_id)
		atlas_texture.get_image().save_png("res://Art/kenney_input-prompts-pixel-16/Tiles/".path_join(key_id) + ".png")

func _duplicate_item_icons_with_red_outline() -> void:
	var red_outline_color: Color = Color.DARK_RED

	for item_path: String in SavedData.get_all_items_paths():
		var item: PassiveItem = load(item_path).new()
		var icon_image: Image = item.get_icon().get_image().duplicate(true)

		for x: int in icon_image.get_width():
			for y: int in icon_image.get_height():
				if icon_image.get_pixel(x, y).get_luminance() < 0.15 and icon_image.get_pixel(x, y).a > 0.0:
					icon_image.set_pixel(x, y, red_outline_color)

		var save_path: String = item.get_icon().resource_path.get_base_dir().path_join(item.get_icon().resource_path.get_basename().get_file() + "_cursed.png")
		icon_image.save_png(save_path)

func _input(event: InputEvent) -> void:
	# Fix for godot 4.2
	if not get_tree().current_scene:
		return

	if event.is_action_pressed("ui_toggle_fullscreen"):
		Log.info("F11 pressed, setting fullscreen")
		Settings.toggle_fullscreen()

#	print(event)
#	if event is InputEventMouseMotion:
#		print(event.as_text())
	if ((event is InputEventMouseMotion and (get_tree().current_scene.name == "Menu" or get_tree().paused)) or event is InputEventKey) and mode == Mode.CONTROLLER:
		_change_to_mouse_mode()
	elif ((event is InputEventJoypadMotion and abs((event as InputEventJoypadMotion).axis_value) > 0.15) or event is InputEventJoypadButton) and mode == Mode.MOUSE:
		_change_to_controller_mode(event.device)

## @deprecated
func get_enemy_paths(biome: String) -> Array[String]:
	var enemy_paths: Array[String] = []

	for enemy: Dictionary in ENEMIES.values():
		var enemy_info: Dictionary = enemy.info
		if enemy_info.has("biomes"):
			var enemy_biomes: Array = enemy_info.biomes
			if enemy_biomes.has(biome):
				enemy_paths.push_back(enemy.path)

	return enemy_paths

## Returns the [PackedScene] of the enemy if it finds it, otherwise returns [code]null[/code]
func get_enemy_scene(id: String) -> PackedScene:
	if ENEMIES.has(id.to_snake_case()):
		var enemy_path: String = ENEMIES[id.to_snake_case()].path
		return load(enemy_path)

	return null

func get_enemy_unlock_weapon_on_kills(id: String) -> UnlockWeaponOnKills:
	id = id.to_snake_case()

	if ENEMIES.has(id) and ENEMIES[id].info.has("unlock_weapon_on_kills"):
		return ENEMIES[id].info.unlock_weapon_on_kills

	return null

func _change_to_mouse_mode() -> void:
	mode = Mode.MOUSE

#	# Si estamos en un menu hacemos el mouse visible, ya que en modo mando el mouse esta invisible en los menus
#	if in_menu:
#		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	mode_changed.emit(mode)

func _change_to_controller_mode(device: int) -> void:
	controller_device = device

	var device_name: String = Input.get_joy_name(device)
	if CONTROLLER_TYPES.PS in device_name.to_lower():
		controller_type = CONTROLLER_TYPES.PS
	else:
		controller_type = CONTROLLER_TYPES.XBOX

	mode = Mode.CONTROLLER

#	# En modo mando, escondemos el mouse en los menus
#	if in_menu:
#		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if get_tree().current_scene.name != "Game":
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

	mode_changed.emit(mode)

func get_joypad_event_image_id(event: InputEvent) -> String:
	return Globals.controller_type + "_joypad_button_" + (str((event as InputEventJoypadButton).button_index) if event is InputEventJoypadButton else str((event as InputEventJoypadMotion).axis))

func exit_level(biome: String="", backwards: bool=false) -> void:
	biome = biome.to_lower()
	if biome.is_empty() or biome == SavedData.run_stats.biome:
		if backwards:
			Game.came_from_next_level = true
			SavedData.run_stats.level -= 1
		else:
			SavedData.run_stats.level += 1
		#SceneTransistor.start_transition_to("res://Game.tscn")
	else:
		SavedData.change_biome_by_id_or_path(biome)

	SceneTransistor.start_transition_to("res://Game.tscn")

#func add_weapon_damage_modifier_by_type(type: WeaponData.Type, dam: int) -> void:
#	Weapon._add_damage_modifier_by_type(type, dam)
#	var weapon_type_string: String = WeaponData.Type.keys()[type]
#	var weapons_of_this_type: Array[Node] = get_tree().get_nodes_in_group(weapon_type_string)
#	for weapon: Weapon in weapons_of_this_type:
#		weapon.set_damage(weapon.data.damage + dam)

#func remove_weapon_damage_modifier_by_type(type: WeaponData.Type, dam: int) -> void:
#	Weapon._remove_damage_modifier_by_type(type, dam)
#	var weapon_type_string: String = WeaponData.Type.keys()[type]
#	var weapons_of_this_type: Array[Node] = get_tree().get_nodes_in_group(weapon_type_string)
#	for weapon: Weapon in weapons_of_this_type:
#		weapon.set_damage(weapon.data.damage - dam)

#func add_weapon_damage_modifier_by_subtype(subtype: WeaponData.Subtype, dam: int) -> void:
#	Weapon._add_damage_modifier_by_subtype(subtype, dam)
#	var weapon_type_string: String = WeaponData.Subtype.keys()[subtype]
#	var weapons_of_this_type: Array[Node] = get_tree().get_nodes_in_group(weapon_type_string)
#	for weapon: Weapon in weapons_of_this_type:
#		weapon.set_damage(weapon.data.damage + dam)

#func remove_weapon_damage_modifier_by_subtype(subtype: WeaponData.Subtype, dam: int) -> void:
#	Weapon._remove_damage_modifier_by_subtype(subtype, dam)
#	var weapon_type_string: String = WeaponData.Subtype.keys()[subtype]
#	var weapons_of_this_type: Array[Node] = get_tree().get_nodes_in_group(weapon_type_string)
#	for weapon: Weapon in weapons_of_this_type:
#		weapon.set_damage(weapon.data.damage - dam)

## This function will be called every time we change scene
func _on_scene_changed(new_scene: String) -> void:
	#Weapon.damage_modifiers_by_type = {} # Reset damage modifiers so they don't acummulate
	#Weapon.damage_modifiers_by_subtype = {}
	AcidPuddle.characters_inside = []
	Snake.there_is_a_snake_hugging_the_player = false

	if new_scene.get_basename().get_file().to_lower() == "game" or new_scene.get_basename().get_file().to_lower() == "basecamp":
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		if mode == Mode.CONTROLLER:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func get_atlas_frame(texture: Texture2D, region: Rect2) -> AtlasTexture:
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = region
	return atlas

func get_missing_elements(complete_array: Array, partial_array: Array) -> Array:
	var missing_elements: Array = []

	for element in complete_array:
		if not partial_array.has(element):
			missing_elements.push_back(element)

	return missing_elements

func array_of_paths_to_filenames(array: Array) -> Array:
	return array.duplicate().map(
		func(element: String) -> String:
			return element.get_basename().get_file()
	)

func is_current_language_a_piece_of_shit_that_uses_gender_for_inanimate_objects() -> bool:
	var locale: String = Settings.settings.get_value(Settings.GENERAL_SECTION, "language", TranslationServer.get_locale())
	return locale in ["es", "ca"]

func is_word_feminine(word: String) -> bool:
	assert(is_current_language_a_piece_of_shit_that_uses_gender_for_inanimate_objects())

	return word.to_lower().ends_with("a")

func is_word_plural(word: String) -> bool:
	assert(is_current_language_a_piece_of_shit_that_uses_gender_for_inanimate_objects())

	return word.to_lower().ends_with("s")

func tr_taking_in_mind_shitty_languages(id: String) -> String:
	if is_current_language_a_piece_of_shit_that_uses_gender_for_inanimate_objects():
		var new_id: String = id
		if is_word_feminine(id):
			new_id += "_FEMININE"
		else:
			new_id += "_MASCULINE"
		if is_word_plural(id):
			new_id += "_PLURAL"
		return tr(new_id)
	else:
		return tr(id + "_FEMININE")

func get_unique_locales() -> Array[String]:
	var unique_locales: Array[String] = []

	var loaded_locales: PackedStringArray = TranslationServer.get_loaded_locales()
	Log.debug("Loaded locales: " + str(loaded_locales))
	for locale: String in loaded_locales:
		if not unique_locales.has(locale):
			unique_locales.push_back(locale)

	return unique_locales

func is_steam_enabled() -> bool:
	return platform == Platform.STEAM

func solve_quadratic(a: float, b: float, c: float) -> Dictionary:
	var discriminant: float = b * b - 4 * a * c
	if discriminant < 0:
		return {"solution": false}

	return {
		"solution": true,
		"root_1": (-b + sqrt(discriminant)) / (2 * a),
		"root_2": (-b - sqrt(discriminant)) / (2 * a)
	}
