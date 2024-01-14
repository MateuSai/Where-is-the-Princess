@icon("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/new_mechant_idle_down_01.png")
class_name Character extends CharacterBody2D

const DB: Dictionary = preload("res://Characters/data.csv").records

const DUST_SCENE: PackedScene = preload("res://Characters/Player/Dust.tscn")
const HIT_EFFECT_SCENE: PackedScene = preload("res://Characters/HitEffect.tscn")

const FRICTION: float = 0.15

#var invincible: bool = false
#@export var max_hp: int = 2
#@export var hp: int = 2: set = set_hp
#signal hp_changed(new_hp)

var damage_multiplier: int = 1

var can_move: bool = true

@export var mass: float = 1
@export var acceleration: float = 0.4
@export var max_speed: int = 100

@export var flying: bool = false: set = set_flying

@export var can_be_knocked_back: bool = true

enum Resistance {
	FIRE = 1,
	ACID = 2,
	FREEZE = 4,
	ELECTRICITY = 8,
}
var initial_resistances: int = 0
var resistances: int = 0 # I can't make an exported using an enum to select flags, so, change this variable from the script if you need to

var mov_direction: Vector2 = Vector2.ZERO

var inside_acid: bool = false
var acid_progress: float = 0.0: set = set_acid_progress ## Value between 0 and 1

## The name of the scene file (after removing .tscn)
@onready var id: String = scene_file_path.get_file().trim_suffix(".tscn").to_snake_case()

@onready var state_machine: FiniteStateMachine = get_node("FiniteStateMachine")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = get_node("Sprite2D")
@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
@onready var life_component: LifeComponent = get_node("LifeComponent")
@onready var dust_positions: Node2D = $DustPositions
# @onready var status_conditions_container: HBoxContainer = get_node("StatusConditionsContainer")
@onready var acid_damage_timer: Timer = $AcidDamageTimer


func _ready() -> void:
	life_component.damage_taken.connect(_on_damage_taken)
	life_component.died.connect(_on_died)
	acid_damage_timer.timeout.connect(_on_acid_damage_timer_timeout)

	if DB.has(id):
		var weapon_data: Dictionary = DB[id]
		_load_csv_data(weapon_data)

	set_flying(flying)
	state_machine.start()


func _load_csv_data(data: Dictionary) -> void:
	life_component.max_hp = data.max_hp
	life_component.hp = data.max_hp

	mass = data.mass
	acceleration = data.acceleration
	max_speed = data.max_speed
	var flying_int: int = data.flying
	flying = bool(flying_int)
	var can_be_knocked_back_int: int = data.can_be_knocked_back
	can_be_knocked_back = bool(can_be_knocked_back_int)
	@warning_ignore("int_as_enum_without_cast")
	life_component.body_type = life_component.BodyType.keys().find(data.body_type)
	initial_resistances = data.resistances
	resistances = data.resistances


func _physics_process(delta: float) -> void:
	if inside_acid and acid_damage_timer.is_stopped():
		acid_progress += 0.7 * delta
	elif acid_progress > 0.0 and not inside_acid:
		acid_progress -= 0.7 * delta

	state_machine.physics_process(delta)
	if can_move:
		move_and_slide()
	velocity = lerp(velocity, Vector2.ZERO, FRICTION)


func move() -> void:
	mov_direction = mov_direction.limit_length(1.0)
	#velocity += mov_direction * acceleration
	if not mov_direction.is_equal_approx(Vector2.ZERO):
		velocity = lerp(velocity, mov_direction * max_speed, acceleration)
	#print_debug(velocity)
	velocity = velocity.limit_length(max_speed)


func add_status_condition(status: StatusComponent.Status) -> void:
	var status_key: String = StatusComponent.Status.keys()[status]
	var status_component: StatusComponent = get_node_or_null(status_key)
	if status_component == null:
		status_component = [FireStatusComponent.new(), IceStatusComponent.new(), LightningStatusComponent.new()][status]
		add_child(status_component)
		status_component.name = StatusComponent.Status.keys()[status]
	status_component.add()


func _on_damage_taken(_dam: int, dir: Vector2, force: int) -> void:
#	if invincible:
#		return

	#if state_machine.state != state_machine.states.hurt and state_machine.state != state_machine.states.dead:
	_spawn_hit_effect()
	#	self.hp -= dam
#		if hp > 0:
			#state_machine.set_state(state_machine.states.hurt)
	if can_be_knocked_back:
		velocity += dir * force / (mass / 3)
	if life_component.hp == 0:
		assert(state_machine.get("DEAD") != null)
		@warning_ignore("unsafe_property_access", "unsafe_call_argument")
		state_machine.set_state(state_machine.DEAD)
		if can_be_knocked_back:
			velocity += dir * force / (mass / 3)


#func set_hp(new_hp: int) -> void:
#	hp = clamp(new_hp, 0, max_hp)
#	emit_signal("hp_changed", hp)


func _spawn_hit_effect() -> void:
	var hit_effect: Sprite2D = HIT_EFFECT_SCENE.instantiate()
	add_child(hit_effect)


func _on_died() -> void:
	pass


func spawn_dust() -> void:
	for dust_position: Marker2D in dust_positions.get_children():
		var dust: Sprite2D = DUST_SCENE.instantiate()
		dust.position = dust_position.position + position
		get_parent().get_child(get_index() - 1).add_sibling(dust)


func set_acid_progress(new_value: float) -> void:
	acid_progress = clamp(new_value, 0.0, 1.0)

	if acid_progress == 1.0:
		sprite.modulate = Color.GREEN
		acid_damage_timer.start()
		_on_acid_damage_timer_timeout()


func start_progressing_acid() -> void:
	inside_acid = true


func stop_progressing_acid() -> void:
	inside_acid = false
	sprite.modulate = Color.WHITE
	acid_damage_timer.stop()


func _on_acid_damage_timer_timeout() -> void:
	life_component.take_damage(1, Vector2.ZERO, 0, null)


func add_resistance(resistance: Resistance) -> void:
	resistances |= resistance


func remove_resistance(resistance: Resistance) -> void:
	resistances &= ~resistance


func has_resistance(resistance: Resistance, initially: bool = false) -> bool:
	if initially:
		return initial_resistances & resistance
	else:
		return resistances & resistance


func set_flying(new_value: bool) -> void:
	flying = new_value


func get_exclude_bodies() -> Array[Node2D]:
	return [self]
