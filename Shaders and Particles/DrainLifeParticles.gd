class_name DrainLifeParticles extends GPUParticles2D

var character_to_drain_life: Character = null
var character_to_give_life: Character = null


func _init() -> void:
	set_process(false)


func _ready() -> void:
	$CompleteDrainingTimer.timeout.connect(func():
		set_process(false)
		character_to_give_life.life_component.hp += 1
		character_to_drain_life.life_component.hp -= 1
		queue_free()
	)


func start_draining(from: Character, to: Character) -> void:
	character_to_drain_life = from
	character_to_give_life = to

	character_to_drain_life.life_component.died.connect(func():
		set_process(false)
		queue_free()
	)
	character_to_give_life.life_component.died.connect(func():
		set_process(false)
		queue_free()
	)

	set_process(true)


func _process(delta: float) -> void:
	position = character_to_drain_life.global_position
	rotation = (character_to_give_life.global_position - character_to_drain_life.global_position).angle()
	lifetime = (character_to_give_life.global_position - character_to_drain_life.global_position).length() / process_material.initial_velocity_min
