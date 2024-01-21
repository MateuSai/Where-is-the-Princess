extends VBoxContainer

static var is_visible: bool = false

@onready var fps_label: Label = get_node("FpsLabel")
@onready var memory_label: Label = get_node("MemoryLabel")
@onready var memory_peak_label: Label = get_node("MemoryPeakLabel")


func _ready() -> void:
	if is_visible:
		show()
	else:
		hide()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_pressed() and (event as InputEventKey).keycode == KEY_F2:
			if visible:
				is_visible = false
				hide()
				set_process(false)
			else:
				is_visible = true
				show()
				set_process(true)


func _process(_delta: float) -> void:
	fps_label.text = str("FPS: ", Engine.get_frames_per_second())
	memory_label.text = str(snappedf(OS.get_static_memory_usage() / 1000000.0, 0.01)) + " MB"
	memory_peak_label.text = tr("Peak") + ": " + str(snappedf(OS.get_static_memory_peak_usage() / 1000000.0, 0.01)) + " MB"
