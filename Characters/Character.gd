@icon("res://Art/v1.1 dungeon crawler 16x16 pixel pack/heroes/knight/knight_idle_anim_f0.png")

class_name Character extends CharacterBody2D

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
@export var accerelation: int = 40
@export var max_speed: int = 100

@export var flying: bool = false

@export var can_be_knocked_back: bool = true

@onready var state_machine: Node = get_node("FiniteStateMachine")
@onready var sprite: Sprite2D = get_node("Sprite2D")
@onready var collision_shape: CollisionShape2D = get_node("CollisionShape2D")
@onready var life_component: LifeComponent = get_node("LifeComponent")
@onready var dust_positions: Node2D = $DustPositions
# @onready var status_conditions_container: HBoxContainer = get_node("StatusConditionsContainer")

var mov_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	life_component.damage_taken.connect(_on_damage_taken)
	life_component.died.connect(_on_died)


func _physics_process(_delta: float) -> void:
	move_and_slide()
	velocity = lerp(velocity, Vector2.ZERO, FRICTION)


func move() -> void:
	mov_direction = mov_direction.normalized()
	velocity += mov_direction * accerelation
	velocity = velocity.limit_length(max_speed)


func add_status_condition(status: StatusComponent.Status) -> void:
	var status_component: StatusComponent = get_node_or_null(StatusComponent.Status.keys()[status])
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
		state_machine.set_state(state_machine.states.dead)
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
	for dust_position in dust_positions.get_children():
		var dust: Sprite2D = DUST_SCENE.instantiate()
		dust.position = dust_position.position + position
		get_parent().get_child(get_index() - 1).add_sibling(dust)
