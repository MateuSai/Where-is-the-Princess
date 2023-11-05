extends Node

var run_seed: int

signal room_closed()
signal room_cleared()

var player: Player = null

var debug: bool = false

const ENEMIES_FOLDER_PATH: String = "res://Characters/Enemies/"
var ENEMIES = {}

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
signal mode_changed(new_mode)
var controller_device: int
var controller_type: String
const CONTROLLER_TYPES = {
	PS = "ps",
	XBOX = "xbox",
}


func _ready() -> void:
	debug = OS.get_cmdline_user_args().has("--debug")

	var enemies_folder: DirAccess = DirAccess.open(ENEMIES_FOLDER_PATH)
	assert(enemies_folder != null)
	for enemy_folder in enemies_folder.get_directories():
		if not enemies_folder.file_exists(enemy_folder + "/" + enemy_folder + ".tscn"):
			push_error(enemy_folder + "/" + enemy_folder + ".tscn" + " not found on " + ENEMIES_FOLDER_PATH)
			continue
		var info: Dictionary = {}
		var info_file: FileAccess = FileAccess.open(ENEMIES_FOLDER_PATH + enemy_folder + "/" + "info.json", FileAccess.READ)
		if info_file != null:
			var json: JSON = JSON.new()
			json.parse(info_file.get_as_text())
			info_file.close()
			info = json.data
		ENEMIES[enemy_folder] = {
			"path": ENEMIES_FOLDER_PATH + enemy_folder + "/" + enemy_folder + ".tscn",
			"info": info,
		}

	SceneTransistor.scene_changed.connect(_on_scene_changed)

	#print(ENEMIES)


func get_enemy_paths(biome: String) -> Array[String]:
	var enemy_paths: Array[String] = []

	for enemy in ENEMIES.values():
		if enemy.info.has("biomes"):
			if enemy.info.biomes.has(biome):
				enemy_paths.push_back(enemy.path)

	return enemy_paths


func _change_to_mouse_mode() -> void:
	mode = Mode.MOUSE

#	# Si estamos en un menu hacemos el mouse visible, ya que en modo mando el mouse esta invisible en los menus
#	if in_menu:
#		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

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

	mode_changed.emit(mode)


func get_joypad_event_image_id(event: InputEventJoypadButton) -> String:
	return Globals.controller_type + "_joypad_button_" + str(event.button_index)


func exit_level(biome: String = "") -> void:
	if biome.is_empty() or biome == SavedData.run_stats.biome:
		SavedData.run_stats.level += 1
		#SceneTransistor.start_transition_to("res://Game.tscn")
	else:
		SavedData.change_biome(biome)

	SceneTransistor.start_transition_to("res://Game.tscn")


func add_weapon_damage_modifier_by_type(type: Weapon.Type, dam: int) -> void:
	Weapon._add_damage_modifier_by_type(type, dam)
	var weapons_of_this_type: Array[Node] = get_tree().get_nodes_in_group(Weapon.Type.keys()[type])
	for weapon in weapons_of_this_type:
		weapon.damage += dam


func remove_weapon_damage_modifier_by_type(type: Weapon.Type, dam: int) -> void:
	Weapon._remove_damage_modifier_by_type(type, dam)
	var weapons_of_this_type: Array[Node] = get_tree().get_nodes_in_group(Weapon.Type.keys()[type])
	for weapon in weapons_of_this_type:
		weapon.damage -= dam


## This function will be called every time we change scene
func _on_scene_changed(_new_scene: String) -> void:
	Weapon.damage_modifiers_by_type = {} # Reset damage modifiers so they don't acummulate
	AcidPuddle.characters_inside = []
