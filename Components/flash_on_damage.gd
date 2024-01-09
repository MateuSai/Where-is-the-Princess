class_name FlashOnDamage extends Node

var timer: Timer
var sprite: Sprite2D
var life_component: LifeComponent


func _ready() -> void:
	sprite = get_node_or_null("../Sprite2D")
	assert(sprite)
	life_component = get_node_or_null("../LifeComponent")
	assert(life_component)
	timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 0.1
	timer.timeout.connect(func() -> void:
		(sprite.material as ShaderMaterial).set_shader_parameter("active", false)
	)
	add_child(timer)

	sprite.material = ShaderMaterial.new()
	(sprite.material as ShaderMaterial).shader = load("res://shaders_and_particles/white.gdshader")

	life_component.damage_taken.connect(func(_dam: int, _dir: Vector2, _force: int) -> void:
		if timer.is_stopped():
			(sprite.material as ShaderMaterial).set_shader_parameter("active", true)
			timer.start()
	)
