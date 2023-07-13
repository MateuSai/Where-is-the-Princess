class_name StatusComponent extends TextureProgressBar

var life_component: LifeComponent

var start_decreasing_after_timer: Timer
var value_tween: Tween

enum Status {
	FIRE,
}


@warning_ignore("shadowed_variable_base_class")
func initialize(texture_under: Texture, texture_progress: Texture) -> void:
	self.texture_under = texture_under
	self.texture_progress = texture_progress


func _init() -> void:
	fill_mode = FILL_BOTTOM_TO_TOP


func _ready() -> void:
	life_component = get_node_or_null("../../LifeComponent")
	assert(life_component != null)

	start_decreasing_after_timer = Timer.new()
	start_decreasing_after_timer.one_shot = true
	start_decreasing_after_timer.timeout.connect(func():
		if value_tween:
			value_tween.kill()
		value_tween = create_tween()
		value_tween.tween_property(self, "value", 0, value/20)
		value_tween.finished.connect(queue_free)
	)
	add_child(start_decreasing_after_timer)


func add(amount: int) -> void:
	if value_tween:
		value_tween.kill()
		value_tween = null

	value += amount
	# print(value)
	if value >= 100:
		life_component.take_damage(1, Vector2.ZERO, 0)
		queue_free()
	else:
		start_decreasing_after_timer.start()
