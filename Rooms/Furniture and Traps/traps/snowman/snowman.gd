class_name Snowman extends StaticBody2D

var is_thief_inside: bool = randi() % 2

@onready var room: DungeonRoom = owner

@onready var player_detector: Area2D = $PlayerDetector

func _ready() -> void:
	if not is_thief_inside:
		player_detector.queue_free()
	else:
		player_detector.body_entered.connect(func(body: Node2D) -> void:
			assert(body is Player)
			var thief: Enemy=Globals.get_enemy_scene("thief").instantiate()
			thief.position=position
			room.call_deferred("add_enemy", thief)
			queue_free()
		)
