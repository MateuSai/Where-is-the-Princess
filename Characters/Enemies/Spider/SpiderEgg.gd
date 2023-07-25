class_name SpiderEgg extends Enemy


const SPIDER_SCENE: PackedScene = preload("res://Characters/Enemies/Spider/Spider.tscn")


func _ready() -> void:
	super()

	$HatchTimer.timeout.connect(func():
		spawn_spiders()
		queue_free()
	)


func spawn_spiders() -> void:
	var spider_amount: int = randi_range(3, 5)
	var initial_angle: float = randf_range(0, 2*PI/spider_amount)
	for i in randi_range(3, 5):
		var spider: Spider = SPIDER_SCENE.instantiate()
		spider.position = position + Vector2.RIGHT.rotated(initial_angle + i * 2*PI/spider_amount) * 4
		get_parent().add_child(spider)
