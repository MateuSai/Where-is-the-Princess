class_name StatusInflicterComponent extends Node

const PARTICLES_SCENES: Array[PackedScene] = [ preload ("res://shaders_and_particles/particles/weapon_status_effect/fire_particles.tscn")]

@export var status: StatusComponent.Status

var change_to_inflict_status_effect: int = 50

@onready var weapon: MeleeWeapon = get_parent()

func _ready() -> void:
	if PARTICLES_SCENES.size() >= status + 1 and PARTICLES_SCENES[status] != null:
		weapon.weapon_sprite.add_child(PARTICLES_SCENES[status].instantiate())

	#await owner.ready
	var hitbox: Hitbox = weapon.hitbox
	hitbox.collided_with_something.connect(func(body: Node2D) -> void:
		if body is Character:
			if randi() % 100 < change_to_inflict_status_effect:
				(body as Character).add_status_condition(status)
	)

#	match status:
#		StatusComponent.Status.FIRE:
#			get_parent().weapon_sprite.modulate = Color.ORANGE_RED
