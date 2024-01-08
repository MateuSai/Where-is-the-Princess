class_name Crossbow extends BowOrCrossbowWeapon


const TIGHTENED_FRAME: int = 0
const RELEASED_FRAME: int = 1

const RELOAD_SOUNDS: Array[AudioStream] = [preload("res://Audio/Sounds/crossbow_reload/350345__nettimato__mini-crossbow-foley_1.wav"), preload("res://Audio/Sounds/crossbow_reload/350345__nettimato__mini-crossbow-foley_2.wav")]


func _ready() -> void:
	super()

	normal_attack_projectile_speed = 500


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_attack") and not is_busy():
		match weapon_sprite.frame:
			TIGHTENED_FRAME:
				_attack()
			RELEASED_FRAME:
				_reload()
			_:
				@warning_ignore("assert_always_true")
				assert(true)

	if event.is_action_pressed("ui_weapon_ability") and has_active_ability() and not is_busy() and can_active_ability():
		_active_ability()


func _reload() -> void:
	animation_player.play(get_animation_full_name("reload"))
	var sound: AutoFreeSound = AutoFreeSound.new()
	get_tree().current_scene.add_child(sound)
	sound.start(RELOAD_SOUNDS[randi() % RELOAD_SOUNDS.size()], global_position)
