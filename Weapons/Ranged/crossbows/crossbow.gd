@icon("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/weapons/weapon icons/Wooden_crossbow_icon.png")
class_name Crossbow extends BowOrCrossbowWeapon


const TIGHTENED_FRAME: int = 0
const RELEASED_FRAME: int = 1

const RELOAD_SOUNDS: Array[AudioStream] = [preload("res://Audio/Sounds/crossbow_reload/350345__nettimato__mini-crossbow-foley_1.wav"), preload("res://Audio/Sounds/crossbow_reload/350345__nettimato__mini-crossbow-foley_2.wav")]

signal reloaded()


func _ready() -> void:
	super()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_attack") and not is_busy():
		if weapon_sprite.frame == TIGHTENED_FRAME:
			_attack()
		elif weapon_sprite.frame == RELEASED_FRAME and can_attack():
			_reload()
		else:
			@warning_ignore("assert_always_true")
			assert(true)

	if event.is_action_pressed("ui_weapon_ability") and has_active_ability() and not is_busy() and can_active_ability():
		_active_ability()


func _reload() -> void:
	animation_player.play(get_animation_full_name("reload"))
	var sound: AutoFreeSound = AutoFreeSound.new()
	get_tree().current_scene.add_child(sound)
	sound.start(RELOAD_SOUNDS[randi() % RELOAD_SOUNDS.size()], global_position)

	reloaded.emit()

static func get_data(path: String) -> WeaponData:
	var id: String = get_id_from_path(path)
	if DB.has(id):
		return CrossbowData.from_dic(DB[id])
	else:
		var data_path: String = path.replace(path.get_file(), "data.tres")
		if FileAccess.file_exists(data_path):
			return load(data_path)

	return null
