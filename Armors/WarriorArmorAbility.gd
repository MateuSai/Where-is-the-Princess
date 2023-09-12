extends GPUParticles2D

@onready var area: Area2D = $Area2D


func _init() -> void:
	one_shot = true
	emitting = true


func _ready() -> void:
	area.body_entered.connect(func(body: Node2D):
		assert(body is Enemy)
		body.velocity += (body.global_position - position).normalized() * 3000
	)
	area.area_entered.connect(func(area: Area2D):
		if area is Projectile:
			area.destroy()
	)
