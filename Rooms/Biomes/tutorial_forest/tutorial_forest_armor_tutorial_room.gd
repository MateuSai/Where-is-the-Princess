extends DungeonRoom

func _ready() -> void:
    super()

    await rooms.game.player_added

    Globals.player.life_component.damage_taken.connect(_on_player_damage_taken)

func _on_player_damage_taken(dam: int, _dir: Vector2, _force: int) -> void:
    if Globals.player.armor is Underpants:
        Globals.player.life_component.hp += dam
    else:
        Globals.player.armor.condition += dam
        
    if Globals.player.life_component.last_damage_dealer_id == "spikes":
        Globals.player.global_position = teleport_position.global_position