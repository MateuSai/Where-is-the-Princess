class_name Lever extends Trigger

@export var time_to_return_to_initial_state: float = -1
var timer: Timer

@onready var sprite: Sprite2D = $Sprite2D
@onready var life_component: LifeComponent = $LifeComponent

func _ready() -> void:
    if time_to_return_to_initial_state != - 1:
        timer = Timer.new()
        timer.one_shot = true
        add_child(timer)
        timer.timeout.connect(func() -> void:
            hit(0)
        )

    life_component.damage_taken.connect(func(dam: int, _dir: Vector2, _force: int) -> void:
        hit(dam)
    )

func hit(dam: int) -> void:
    Log.debug("Lever hitted")

    life_component.hp += dam
    sprite.frame = wrapi(sprite.frame + 1, 0, 2)
    sprite.position = [Vector2(0, -5), Vector2( - 3, -5)][sprite.frame]
    activate()

    if time_to_return_to_initial_state != - 1 and sprite.frame == 1:
        timer.start(time_to_return_to_initial_state)
    elif time_to_return_to_initial_state != - 1 and sprite.frame == 0 and not timer.is_stopped():
        timer.stop()