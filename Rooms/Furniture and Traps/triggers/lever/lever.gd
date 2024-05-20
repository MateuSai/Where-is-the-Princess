class_name Lever extends Trigger

@onready var life_component: LifeComponent = $LifeComponent

func _ready() -> void:
    life_component.damage_taken.connect(func(dam: int, _dir: Vector2, _force: int) -> void:
        Log.debug("Lever hitted")
        life_component.hp += dam
        activate()
    )
