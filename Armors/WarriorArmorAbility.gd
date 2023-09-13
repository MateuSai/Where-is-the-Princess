extends GPUParticles2D

var enemies_inside: Array[Enemy] = []

@onready var area: Area2D = $Area2D


func _init() -> void:
	one_shot = true
	emitting = true


func _ready() -> void:
	area.body_entered.connect(func(body: Node2D):
		assert(body is Enemy)
		enemies_inside.push_back(body)
	)
	area.body_exited.connect(func(body: Node2D):
		assert(body is Enemy)
		enemies_inside.erase(body)
	)
	area.area_entered.connect(func(area_entered: Area2D):
		if area_entered is Projectile:
			area_entered.destroy()
	)


func _physics_process(delta: float) -> void:
	for enemy in enemies_inside:
		enemy.velocity += (enemy.global_position - position).normalized() * 1500 * delta / (enemy.mass / 3)
