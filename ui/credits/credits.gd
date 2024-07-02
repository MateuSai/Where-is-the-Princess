class_name Credits extends ScrollContainer

var scroll_float: float = 0.0

@onready var credits_container: MarginContainer = get_node("MarginContainer")

func _init() -> void:
    RenderingServer.set_default_clear_color(Color.BLACK)

func _ready() -> void:
    scroll_vertical = 0

    if not OS.has_feature("steam"):
        get_node("%Godotsteam").queue_free()

func _process(delta: float) -> void:
    if scroll_vertical + size.y < credits_container.size.y:
        scroll_float += 15 * delta
        scroll_vertical = round(scroll_float)
    else:
        set_process(false)

func _input(event: InputEvent) -> void:
    if (event is InputEventKey and event.keycode in [KEY_ESCAPE]) or (event is InputEventJoypadButton and event.button_index in [JOY_BUTTON_B]):
        SceneTransistor.start_transition_to("res://ui/menu.tscn")
    elif event is InputEventMouseButton and (event as InputEventMouseButton).button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
        set_process(false)