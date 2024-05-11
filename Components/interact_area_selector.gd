class_name InteractAreaSelector extends Area2D

var closer_area: InteractArea = null:
	set(new_closer_area):
		if new_closer_area != closer_area:
			if closer_area:
				closer_area._on_player_exited(player)
				if closer_area.get_parent() is ItemOnFloor:
					InfoPanel.stop_showing()
			closer_area = new_closer_area
			if closer_area:
				closer_area._on_player_entered(player)
				if closer_area.get_parent() is ItemOnFloor and (player.current_room == null or player.current_room.is_cleared()):
					InfoPanel.show_at(closer_area.global_position, (closer_area.get_parent() as ItemOnFloor).item)
var interact_areas: Array[InteractArea] = []

@onready var player: Player = get_parent()

@onready var update_closer_area_timer: Timer = $UpdateCloserAreaTimer

func _ready() -> void:
	$CollisionShape2D.shape.radius = player.get_node("CollisionShape2D").shape.radius

	area_entered.connect(_on_interact_area_entered)
	area_exited.connect(_on_interact_area_exited)

	update_closer_area_timer.timeout.connect(_on_update_closer_area_timer_timeout)

func _on_interact_area_entered(area: Area2D) -> void:
	assert(area is InteractArea)
	interact_areas.push_back(area)

	if interact_areas.size() == 1:
		update_closer_area_timer.start()
		_on_update_closer_area_timer_timeout()

func _on_interact_area_exited(area: Area2D) -> void:
	assert(area is InteractArea)
	interact_areas.erase(area)
	if area == closer_area:
		self.closer_area = null
	if interact_areas.is_empty():
		update_closer_area_timer.stop()

func _on_update_closer_area_timer_timeout() -> void:
	var new_closer_area: InteractArea = null
	var distance_to_new_closer_area: float = INF

	for area: InteractArea in interact_areas:
		var dis: float = (player.position - area.global_position).length()
		if dis < distance_to_new_closer_area:
			new_closer_area = area
			distance_to_new_closer_area = dis

	self.closer_area = new_closer_area
