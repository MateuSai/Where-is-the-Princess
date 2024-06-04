class_name TimeTrigger extends Trigger

@export var interval: float = 0.2

@onready var room: DungeonRoom = owner

func _ready() -> void:
    var timer: Timer = Timer.new()
    timer.timeout.connect(activate)
    add_child(timer)

    room.closed.connect(func() -> void:
        timer.start(interval)
    )
    room.cleared.connect(func() -> void:
        timer.stop()
    )
