class_name NotificationContainer extends MarginContainer

var notification_queue: Array[PackedScene] = []
var arguments_queue: Array[Dictionary] = []

func add_notification_to_queue(notification_scene: PackedScene, arguments: Dictionary) -> void:
	notification_queue.push_back(notification_scene)
	arguments_queue.push_back(arguments)

	if notification_queue.size() == 1:
		_show_next_notification()

func _show_next_notification() -> void:
	var notification_node: Control = notification_queue.front().instantiate()
	notification_node.modulate.a = 0.0
	add_child(notification_node)
	notification_node.initialize(arguments_queue.front())
	size.y = 0
	position.x = ProjectSettings.get_setting("display/window/size/viewport_width", 0) - size.x
	pivot_offset.x = size.x

	var tween: Tween = create_tween()

	tween.finished.connect(func() -> void:
		notification_node.queue_free()
		if not notification_queue.is_empty():
			_show_next_notification()
	)

	tween.tween_property(notification_node, "modulate:a", 1.0, 0.7)
	tween.tween_interval(9)
	tween.tween_property(notification_node, "modulate:a", 0, 0.7)
	tween.finished.connect(func() -> void:
		notification_queue.pop_front()
		arguments_queue.pop_front()
	)
