class_name TutorialForestArmorTutorialRoom extends DungeonRoom

@onready var second_part_area: Area2D = $SecondPartArea

func _ready() -> void:
    super()

    await rooms.game.player_added

    Globals.player.life_component.damage_taken.connect(_on_player_damage_taken)

    player_entered.connect(func() -> void:
        _close_entrance()

        second_part_area.body_entered.connect(func(_body: Node2D) -> void:
            second_part_area.queue_free()
            Globals.player.armor_ability_used.connect(func() -> void:
                Globals.player.life_component.damage_taken.disconnect(_on_player_damage_taken)
                _open_doors()
            , CONNECT_ONE_SHOT)
        )
    , CONNECT_ONE_SHOT)

func _on_player_damage_taken(dam: int, _dir: Vector2, _force: int) -> void:
    if Globals.player.armor is Underpants:
        Globals.player.life_component.hp += dam
    else:
        Globals.player.armor.condition += dam
        
    Log.debug(Globals.player.life_component.last_damage_dealer_id)
    if Globals.player.life_component.last_damage_dealer_id == "arrow_pillar":
        Globals.player.velocity = Vector2.ZERO
        Globals.player.set_deferred("global_position", teleport_position.global_position)