class_name LifeComponent extends Node

var invincible: bool = false
var invincible_after_being_hitted_time: float = 0.3
var invincible_after_being_hitted: bool = false
var invincible_after_being_hitted_timer: Timer

## Value between 0 and 100 where 0 is impossible to block and 100 is 100% blocking probability
var block_probability: int = 0

var damage_taken_multiplier: int = 1

const BONES_HIT_SOUNDS: Array[AudioStream] = [preload("res://Audio/Sounds/impact/420252__redroxpeterpepper__step-skeleton.wav"), preload("res://Audio/Sounds/impact/420253__redroxpeterpepper__step-skeleton-2.wav")]
const WOOD_HIT_SOUNDS: Array[AudioStream] = [preload("res://Audio/Sounds/impact/547414__ian_g__wood-hit.wav")]

var last_weapon: Weapon
var last_damage_dealer_id: String

enum BodyType {
	FLESH,
	SLIME,
	BONES,
	WOOD,
}
@export var body_type: BodyType = BodyType.FLESH

@export var max_hp: int = 4
@export var hp: int:
	set(new_hp):
		hp = clamp(new_hp, 0, max_hp)
		hp_changed.emit(hp)
		if hp == 0:
			died.emit()

signal hp_changed(new_hp: int)
signal damage_taken(dam: int, dir: Vector2, force: int)
signal died()

@onready var parent: Node2D = get_parent()


func _ready() -> void:
	invincible_after_being_hitted_timer = Timer.new()
	invincible_after_being_hitted_timer.one_shot = true
	invincible_after_being_hitted_timer.timeout.connect(func() -> void: invincible_after_being_hitted = false)
	add_child(invincible_after_being_hitted_timer)


func take_damage(dam: int, dir: Vector2, force: int, weapon: Weapon, damage_dealer_id: String) -> void:
	if _must_ignore_damage():
		return

	last_damage_dealer_id = damage_dealer_id
	last_weapon = weapon

	dam *= damage_taken_multiplier
	self.hp -= dam
	_play_hit_sound(weapon)

	damage_taken.emit(dam, dir, force)

	invincible_after_being_hitted = true
	invincible_after_being_hitted_timer.start(invincible_after_being_hitted_time)


func _must_ignore_damage() -> bool:
	if invincible or invincible_after_being_hitted or hp == 0:
		return true

	if block_probability > 0:
		if randi() % 100 < block_probability:
			#print_debug("Blocked")
			var block_sound: AutoFreeSound = AutoFreeSound.new()
			get_tree().current_scene.add_child(block_sound)
			var stream: AudioStream = load("res://Audio/Sounds/Starter Pack-Realist Sound Bank.23/Hammer/HammerMetal1.wav")
			assert(stream)
			block_sound.start(stream, parent.global_position)
			return true

	return false


func _play_hit_sound(weapon: Weapon) -> void:
	if weapon == null:
		return

	var stream: AudioStream = null
	match body_type:
		BodyType.BONES:
			stream = BONES_HIT_SOUNDS[randi() % BONES_HIT_SOUNDS.size()]
		BodyType.WOOD:
			stream = WOOD_HIT_SOUNDS[randi() % WOOD_HIT_SOUNDS.size()]

	if stream:
		var sound: AutoFreeSound = AutoFreeSound.new()
		get_tree().current_scene.add_child(sound)
		sound.start(stream, parent.global_position)

