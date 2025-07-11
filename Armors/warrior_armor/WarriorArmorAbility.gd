extends GPUParticles2D

var enemies_inside: Array[Enemy] = []

@onready var area: Area2D = $Area2D


func _init() -> void:
	one_shot = true
	emitting = true


func _ready() -> void:
	area.body_entered.connect(func(body: Node2D) -> void:
		if not body is Enemy:
			return
		enemies_inside.push_back(body)
	)
	area.body_exited.connect(func(body: Node2D) -> void:
		if not body is Enemy:
			return
		enemies_inside.erase(body)
	)
	area.area_entered.connect(func(area_entered: Area2D) -> void:
		if area_entered is Projectile:
			(area_entered as Projectile).destroy()
	)


func _physics_process(delta: float) -> void:
	for enemy: Enemy in enemies_inside:
		enemy.velocity += (enemy.global_position - position).normalized() * 1500 * delta / (enemy.data.mass / 3)
