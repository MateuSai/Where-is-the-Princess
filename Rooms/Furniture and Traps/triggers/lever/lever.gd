class_name Lever extends Trigger

@onready var sprite: Sprite2D = $Sprite2D
@onready var life_component: LifeComponent = $LifeComponent

func _ready() -> void:
    life_component.damage_taken.connect(func(dam: int, _dir: Vector2, _force: int) -> void:
        Log.debug("Lever hitted")
        life_component.hp += dam
        sprite.frame=wrapi(sprite.frame + 1, 0, 2)
        sprite.position=[Vector2(0, -5), Vector2( - 3, -5)][sprite.frame]
        activate()
    )
