class_name GameUI extends CanvasLayer

# var minimap_visible: bool = false

var in_combat: bool = false

@onready var tab_container: TabContainer = $TabContainer
@onready var minimap: MiniMap = %MINIMAP
@onready var menu: Control = %MENU
@onready var seed_label: Label = %SeedLabel
@onready var color_rect: ColorRect = %UIColorRect


func _ready() -> void:
	Globals.room_closed.connect(func() -> void:
		in_combat = true
		#minimap.hide()
	)
	Globals.room_cleared.connect(func() -> void:
		in_combat = false
	)

	color_rect.hide()
	tab_container.hide()
	#pause_menu.hide()
	seed_label.hide()
	seed_label.text = str(Globals.run_seed)

	#minimap.popup_hide.connect(func(): minimap_visible = false)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_minimap") and not in_combat and not tab_container.visible:
		show_tab_container()
		tab_container.current_tab = minimap.get_index()
		minimap.scroll_to_player()

	if event.is_action_pressed("ui_pause"):
		if tab_container.visible:
			hide_tab_container()
			#pause_menu.hide()
			#color_rect.hide()
			#get_tree().paused = false
		else:
			tab_container.current_tab = menu.get_index()
			show_tab_container()
			#pause_menu.show()
			#color_rect.show()
			#get_tree().paused = true


func show_tab_container() -> void:
	color_rect.show()
	tab_container.show()
	seed_label.show()
	get_tree().paused = true


func hide_tab_container() -> void:
	color_rect.hide()
	tab_container.hide()
	seed_label.hide()
	get_tree().paused = false
