class_name SpiderEgg extends Enemy

var spider_amount: int = randi_range(2, 3)

const SPIDER_SCENE: PackedScene = preload("res://Characters/Enemies/SpiderEgg/Spider.tscn")


func _ready() -> void:
	super()

	$HatchTimer.timeout.connect(func():
#		room.num_enemies += spider_amount
		collision_shape.queue_free()
		$AnimationPlayer.play("hatch")
		life_component.hp = 0
	)


func _on_died() -> void:
	if $AnimationPlayer.current_animation == "hatch":
		return

	super()


func spawn_spiders() -> void:
	var initial_angle: float = randf_range(0, 2*PI/spider_amount)
	for i in spider_amount:
		var spider: Spider = SPIDER_SCENE.instantiate()
		spider.position = position + Vector2.RIGHT.rotated(initial_angle + i * 2*PI/spider_amount) * 4
		room.add_enemy(spider)
