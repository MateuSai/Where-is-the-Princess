class_name SpiderEgg extends Enemy


const SPIDER_SCENE: PackedScene = preload("res://Characters/Enemies/SpiderEgg/Spider.tscn")


func _ready() -> void:
	super()

	$HatchTimer.timeout.connect(func():
		collision_shape.queue_free()
		$AnimationPlayer.play("hatch")
	)


func spawn_spiders() -> void:
	var spider_amount: int = randi_range(2, 3)
	var initial_angle: float = randf_range(0, 2*PI/spider_amount)
	for i in spider_amount:
		var spider: Spider = SPIDER_SCENE.instantiate()
		spider.position = position + Vector2.RIGHT.rotated(initial_angle + i * 2*PI/spider_amount) * 4
		get_parent().add_child(spider)

	room.num_enemies += spider_amount - 1
