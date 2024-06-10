class_name LoadingIcon extends TextureRect

@onready var game: Game = owner

@onready var animation_player: AnimationPlayer = get_node("AnimationPlayer")

func _ready() -> void:
    #animation_player.animation_started.connect(func(_anim_name: String) -> void:
    var armors: PackedStringArray = SavedData.get_available_armor_paths()
    (texture as AtlasTexture).atlas = (load(armors[randi() % armors.size()]).new() as Armor).sprite_sheet
    #)

    game.player_added.connect(func() -> void:
        animation_player.stop()
    )
