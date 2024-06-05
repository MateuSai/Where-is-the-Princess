class_name TutorialForestEndRoom extends DungeonRoom

signal teleported()

@onready var sleep_bag_interact_area: InteractArea = get_node("SleepBag/InteractArea")
@onready var player_teleport_detector: Area2D = get_node("TeleportPosition/PlayerTeleportDetector")

func _ready() -> void:
    super()

    player_teleport_detector.body_entered.connect(func(_body: Node2D) -> void:
        player_teleport_detector.queue_free()
        teleported.emit()
    , CONNECT_ONE_SHOT)

    sleep_bag_interact_area.player_interacted.connect(func() -> void:
        sleep_bag_interact_area.queue_free()
        SavedData.reset_run_stats()
        SavedData.change_biome_by_id_or_path("basecamp")
        SceneTransistor.start_transition_to("res://Game.tscn")
    , CONNECT_ONE_SHOT)