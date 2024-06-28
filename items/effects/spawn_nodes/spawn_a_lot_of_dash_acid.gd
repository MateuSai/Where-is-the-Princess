class_name SpawnALotOfDashAcid extends SpawnSceneAtPlayerPosition

const ACID_PUDDLE_SCENE: PackedScene = preload ("res://Characters/Enemies/medium_slime/acid_puddle.tscn")

func _init() -> void:
    super(
        ACID_PUDDLE_SCENE,
        14.0,
        Player.DASH_TIME * 2.5,
        0.008
    )

func get_description() -> String:
    return _get_color_tag(GREEN) % tr("SPAWN_A_LOT_OF_DASH_ACID")
