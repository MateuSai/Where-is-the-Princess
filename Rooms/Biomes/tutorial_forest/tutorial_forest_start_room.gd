class_name TutorialForestStartRoom extends DungeonRoom

signal player_exited()

@onready var player_exited_detector: Area2D = $PlayerExitDetector

func _ready() -> void:
    super()

    player_exited_detector.body_entered.connect(func(_body: Node2D) -> void:
        player_exited_detector.queue_free()
        player_exited.emit()
    , CONNECT_ONE_SHOT)
    