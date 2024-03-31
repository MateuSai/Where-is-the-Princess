class_name LifeComponent extends Node

var invincible: bool = false
var invincible_after_being_hitted_time: float = 0.3
var invincible_after_being_hitted: bool = false
var invincible_after_being_hitted_timer: Timer

## Value between 0 and 100 where 0 is impossible to block and 100 is 100% blocking probability
var block_probability: int = 0

var thorn_damage: int = 0
signal thorn_damage_used()

var damage_taken_multiplier: int = 1
var extra_damage_taken: int = 0

const BONES_HIT_SOUNDS: Array[AudioStream] = [preload("res://Audio/Sounds/impact/420252__redroxpeterpepper__step-skeleton.wav"), preload("res://Audio/Sounds/impact/420253__redroxpeterpepper__step-skeleton-2.wav")]
const WOOD_HIT_SOUNDS: Array[AudioStream] = [preload("res://Audio/Sounds/impact/547414__ian_g__wood-hit.wav")]

var last_weapon: Weapon
var last_damage_dealer_id: String
var last_is_ranged: bool

enum BodyType {
	FLESH,
	SLIME,
	BONES,
	WOOD,
}
@export var body_type: BodyType = BodyType.FLESH

var _set_hp: Callable = func(new_hp: int) -> void:
	hp_changed.emit(hp)
	if hp == 0:
		died.emit()

@export var max_hp: int = 4
@export var hp: int:
	set(new_hp):
		hp = clamp(new_hp, 0, max_hp)
		_set_hp.call(new_hp)

signal hp_changed(new_hp: int)
signal damage_taken(dam: int, dir: Vector2, force: int)
signal died()

@onready var parent: Node2D = get_parent()


func _ready() -> void:
	invincible_after_being_hitted_timer = Timer.new()
	invincible_after_being_hitted_timer.one_shot = true
	invincible_after_being_hitted_timer.timeout.connect(func() -> void: invincible_after_being_hitted = false)
	add_child(invincible_after_being_hitted_timer)


func take_damage(dam: int, dir: Vector2, force: int, weapon: Weapon, damage_dealer: Node, damage_dealer_id: String, is_ranged: bool = false) -> void:
	if _must_ignore_damage():
		return

	last_damage_dealer_id = damage_dealer_id
	last_weapon = weapon
	last_is_ranged = is_ranged

	dam = dam * damage_taken_multiplier + extra_damage_taken
	self.hp -= dam
	_play_hit_sound(weapon)

	damage_taken.emit(dam, dir, force)
	Globals.character_received_damage.emit(parent, damage_dealer)

	invincible_after_being_hitted = true
	invincible_after_being_hitted_timer.start(invincible_after_being_hitted_time)

	if not is_ranged and damage_dealer and damage_dealer.has_node("LifeComponent") and thorn_damage:
		_apply_thorn_damage(damage_dealer)


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


func _apply_thorn_damage(to: Node) -> void:
	(to.get_node("LifeComponent") as LifeComponent).take_damage(thorn_damage, (to.global_position - get_parent().global_position).normalized(), 300, null, null, "thorn")
	thorn_damage_used.emit()
