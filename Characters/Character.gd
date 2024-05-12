@icon("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/characters/new_mechant_idle_down_01.png")
class_name Character extends CharacterBody2D

const DB: Dictionary = preload ("res://Characters/data.csv").records

const DUST_SCENE: PackedScene = preload ("res://Characters/Player/Dust.tscn")
const HIT_EFFECT_SCENE: PackedScene = preload ("res://Characters/HitEffect.tscn")

const FRICTION: float = 0.15
var friction: float = FRICTION

#var invincible: bool = false
#@export var max_hp: int = 2
#@export var hp: int = 2: set = set_hp
#signal hp_changed(new_hp)

var damage_multiplier: float = 1.0

var can_move: bool = true

var data: CharacterData

enum Resistance {
	FIRE = 1,
	ACID = 2,
	FREEZE = 4,
	ELECTRICITY = 8,
}
var resistances: int = 0

var previous_max_speed: int
var dash_time: float = 0.06
var dash_timer: Timer
var dash_cooldown_timer: Timer

var mov_direction: Vector2 = Vector2.ZERO

var inside_acid: bool = false
var acid_progress_per_second: float = 0.7
var time_between_acid_damages: float = 1.0:
	set(new_value):
		time_between_acid_damages = new_value
		acid_damage_timer.wait_time = time_between_acid_damages
var acid_progress: float = 0.0: set = set_acid_progress # # Value between 0 and 1

var spawn_shadow_timer: Timer

var behavior_tree: BeehaveTree

## The name of the scene file after removing .tscn and converting it to snake_case
@onready var id: String = scene_file_path.get_file().trim_suffix(".tscn").to_snake_case()

@onready var state_machine: FiniteStateMachine = get_node("FiniteStateMachine")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = get_node("Sprite2D")
@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
@onready var life_component: LifeComponent = get_node("LifeComponent")
@onready var dust_positions: Node2D = $DustPositions
# @onready var status_conditions_container: HBoxContainer = get_node("StatusConditionsContainer")
@onready var acid_damage_timer: Timer = $AcidDamageTimer

@onready var state_label: Label = $StateLabel

func _ready() -> void:
	life_component.damage_taken.connect(_on_damage_taken)
	life_component.died.connect(_on_died)
	acid_damage_timer.timeout.connect(_on_acid_damage_timer_timeout)

	#if DB.has(id):
		#var weapon_data: Dictionary = DB[id]
		#_load_csv_data(weapon_data)

	_load_data()
	assert(data)
	life_component.max_hp = data.max_hp
	life_component.hp = data.max_hp
	life_component.body_type = data.body_type
	resistances = data.initial_resistances

	spawn_shadow_timer = Timer.new()
	spawn_shadow_timer.wait_time = 0.02
	spawn_shadow_timer.autostart = false
	spawn_shadow_timer.one_shot = false
	spawn_shadow_timer.timeout.connect(_spawn_shadow_effect)
	add_child(spawn_shadow_timer)

	dash_timer = Timer.new()
	dash_timer.one_shot = true
	add_child(dash_timer)
	dash_cooldown_timer = Timer.new()
	dash_cooldown_timer.one_shot = true
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	add_child(dash_cooldown_timer)

	set_flying(data.flying)

	if DebugInfo.is_visible:
		state_label.show()
		state_machine.state_changed.connect(_update_state_label)
	else:
		state_label.hide()
	(get_tree().current_scene.get_node("UI/DebugUI/DebugInfo") as DebugInfo).visibility_changed.connect(func() -> void:
		if state_label.visible:
			state_machine.state_changed.disconnect(_update_state_label)
			state_label.hide()
		else:
			state_label.show()
			state_machine.state_changed.connect(_update_state_label)
	)
	state_machine.start()

	for child: Node in get_children():
		if child is BeehaveTree:
			behavior_tree = child
			break

func _load_data() -> void:
	data = Character.get_data(id)

#func _load_csv_data(data: Dictionary) -> void:
	#life_component.max_hp = data.max_hp
	#life_component.hp = data.max_hp
#
	#@warning_ignore("int_as_enum_without_cast")
	#life_component.body_type = life_component.BodyType.keys().find(data.body_type)
	#resistances = data.resistances

func _physics_process(delta: float) -> void:
	if inside_acid and acid_damage_timer.is_stopped():
		acid_progress += acid_progress_per_second * delta
	elif acid_progress > 0.0 and not inside_acid:
		acid_progress -= 0.7 * delta

	if state_machine:
		state_machine.physics_process(delta)

	_move()

	if not data.motionless:
		move_and_slide()
	velocity = lerp(velocity, Vector2.ZERO, friction)

func _move() -> void:
	mov_direction = mov_direction.limit_length(1.0)
	#velocity += mov_direction * acceleration
	if not mov_direction.is_equal_approx(Vector2.ZERO) and can_move:
		velocity = lerp(velocity, mov_direction * data.max_speed, data.acceleration)
	#print_debug(velocity)
	#velocity = velocity.limit_length(data.max_speed)

func add_status_condition(status: StatusComponent.Status) -> void:
	var status_key: String = StatusComponent.Status.keys()[status]
	var status_component: StatusComponent = get_node_or_null(status_key)
	if status_component == null:
		status_component = load(["res://Components/status_components/FireStatusComponent.gd", "res://Components/status_components/IceStatusComponent.gd", "res://Components/status_components/LightningStatusComponent.gd", "res://Components/status_components/acid_status_component.gd"][status]).new()
		add_child(status_component)
		status_component.name = StatusComponent.Status.keys()[status]
	status_component.add()

func _on_damage_taken(_dam: int, dir: Vector2, force: int) -> void:
	Log.debug(id + " has taken damage with a force of " + str(force) + " and a direction of " + str(dir))
#	if invincible:
#		return

	#if state_machine.state != state_machine.states.hurt and state_machine.state != state_machine.states.dead:
	_spawn_hit_effect()
	#	self.hp -= dam
#		if hp > 0:
			#state_machine.set_state(state_machine.states.hurt)
	if data.can_be_knocked_back:
		velocity += dir * force / (data.mass / 3)
	if life_component.hp == 0:
		mov_direction = Vector2.ZERO

		if behavior_tree:
			behavior_tree.queue_free()
		elif state_machine:
			assert(state_machine.get("DEAD") != null)
			@warning_ignore("unsafe_property_access", "unsafe_call_argument")
			state_machine.set_state(state_machine.DEAD)

		if data.can_be_knocked_back:
			velocity += dir * force / (data.mass / 3)

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

func react(reaction_face: int, at_pos: Vector2=Vector2(0, -34)) -> void:
	var reaction: Reaction = load("res://ui/reactions/reaction.tscn").instantiate()
	reaction.position = at_pos
	add_child(reaction)
	reaction.react(reaction_face)

func set_flying(new_value: bool) -> void:
	data.flying = new_value

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
	life_component.take_damage(1, Vector2.ZERO, 0, null, null, "acid")

func add_resistance(resistance: Resistance) -> void:
	resistances |= resistance

func remove_resistance(resistance: Resistance) -> void:
	resistances &= ~resistance

func has_resistance(resistance: Resistance, initially: bool=false) -> bool:
	if initially:
		return data.initial_resistances&resistance
	else:
		return resistances&resistance

func get_exclude_bodies() -> Array[Node2D]:
	return [self]

func _start_shadow_effect() -> void:
	_spawn_shadow_effect()
	spawn_shadow_timer.start()

func _stop_shadow_effect() -> void:
	spawn_shadow_timer.stop()

func _spawn_shadow_effect() -> void:
	var shadow_sprite: ShadowSprite = ShadowSprite.new()
	shadow_sprite.modulate.a = 1.0
	shadow_sprite.scale = sprite.scale
	shadow_sprite.flip_h = sprite.flip_h
	shadow_sprite.flip_v = sprite.flip_v
	shadow_sprite.hframes = sprite.hframes
	shadow_sprite.vframes = sprite.vframes
	shadow_sprite.transform = sprite.global_transform
	#shadow_sprite.position = weapon_sprite.global_position
	#shadow_sprite.rotation = weapon_sprite.global_rotation
	shadow_sprite.offset = sprite.offset
	get_tree().current_scene.add_child(shadow_sprite)
	shadow_sprite.start(sprite.texture)

func _dash(dash_time: float=dash_time) -> void:
	print_debug("dash " + str(mov_direction))
	dash_cooldown_timer.start()

	#velocity += mov_direction.normalized() * 1000
	#print_debug("Velocity after applying dash: " + str(velocity))
	#mov_direction = Vector2.ZERO
	#friction = 0
	previous_max_speed = data.max_speed
	data.max_speed = 1000
	dash_timer.start(dash_time)
	_start_shadow_effect()

func _on_dash_timer_timeout() -> void:
	print_debug(mov_direction)
	data.max_speed = previous_max_speed
	#friction = FRICTION
	await get_tree().create_timer(0.06).timeout
	_stop_shadow_effect()

func _update_state_label(new_state: int) -> void:
	state_label.text = str(new_state)

@warning_ignore("shadowed_variable")
static func get_data(id: String) -> CharacterData:
	if DB.has(id):
		return CharacterData.from_dic(DB[id])
	else:
		assert(false, "Implement this")
		return null
