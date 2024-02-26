class_name DebugInfo extends VBoxContainer

@warning_ignore("shadowed_variable_base_class")
static var is_visible: bool = false

static var start_time: int

@onready var run_time_label: Label = $RunTimeLabel
@onready var fps_label: Label = get_node("FpsLabel")
@onready var memory_label: Label = get_node("MemoryLabel")
@onready var memory_peak_label: Label = get_node("MemoryPeakLabel")
@onready var video_memory_label: Label = $VideoMemoryLabel
@onready var time_label: Label = $TimeLabel
@onready var nodes_label: Label = $NodesLabel
@onready var orphan_label: Label = $OrphanLabel


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
	run_time_label.text = "Run time: " + str((Time.get_ticks_msec() - start_time) / 1000.0)

	fps_label.text = str("FPS: ", Engine.get_frames_per_second())
	memory_label.text = "RAM: " + str(snappedf(OS.get_static_memory_usage() / 1000000.0, 0.01)) + " MB"
	memory_peak_label.text = "Peak" + ": " + str(snappedf(OS.get_static_memory_peak_usage() / 1000000.0, 0.01)) + " MB"
	video_memory_label.text = "Video RAM: " + str(snappedf(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1000000.0, 0.01)) + " MB"
	time_label.text = "Day time: " + str(snappedf(DayNightSystem.time, 0.01))

	nodes_label.text = "Num nodes: " + str(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))

	var num_orphans: int = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	if num_orphans:
		orphan_label.modulate = Color.RED
	else:
		orphan_label.modulate = Color.GREEN
	orphan_label.text = "Num orphans: " + str(num_orphans)
