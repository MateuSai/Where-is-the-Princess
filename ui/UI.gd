class_name GameUI extends CanvasLayer

# var minimap_visible: bool = false

var in_combat: bool = false

var viewport_texture: ViewportTexture
var cropped_viewport_texture: ImageTexture

@onready var tab_container: TabContainer = $MenuTabContainer
@onready var minimap: MiniMap = %MAP
@onready var equipment: MarginContainer = %EQUIPMENT
@onready var encyclopedia: MarginContainer = %ENCYCLOPEDIA
@onready var menu: Control = %OPTIONS

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
	seed_label.text = str(SavedData.run_stats.get_level_seed())

	#minimap.popup_hide.connect(func(): minimap_visible = false)


func _unhandled_input(event: InputEvent) -> void:
	if not in_combat:
		if event.is_action_pressed("ui_minimap") and (not tab_container.visible or tab_container.current_tab != minimap.get_index()):
			show_tab_container()
			tab_container.current_tab = minimap.get_index()
		elif event.is_action_pressed("ui_equipment") and (not tab_container.visible or tab_container.current_tab != equipment.get_index()):
			show_tab_container()
			tab_container.current_tab = equipment.get_index()
		elif event.is_action_pressed("ui_encyclopedia") and (not tab_container.visible or tab_container.current_tab != encyclopedia.get_index()):
			show_tab_container()
			tab_container.current_tab = encyclopedia.get_index()
		elif event.is_action_pressed("ui_options_menu") and (not tab_container.visible or tab_container.current_tab != menu.get_index()):
			show_tab_container()
			tab_container.current_tab = menu.get_index()
		else:
			if tab_container.visible:
				if (event.is_action_pressed("ui_minimap") and tab_container.current_tab == minimap.get_index()) or (event.is_action_pressed("ui_equipment") and tab_container.current_tab == equipment.get_index()) or (event.is_action_pressed("ui_encyclopedia") and tab_container.current_tab == encyclopedia.get_index()) or (event.is_action_pressed("ui_options_menu") and tab_container.current_tab == menu.get_index()):
					hide_tab_container()

	if event.is_action_pressed("ui_pause"):
		if tab_container.visible:
			hide_tab_container()
			#pause_menu.hide()
			#color_rect.hide()
			#get_tree().paused = false
		else:
			show_tab_container()
			#pause_menu.show()
			#color_rect.show()
			#get_tree().paused = true


func show_tab_container() -> void:
	viewport_texture = get_viewport().get_texture()
	var image: Image = viewport_texture.get_image()
	var scale_x: float = float(image.get_width()) / ProjectSettings.get_setting("display/window/size/viewport_width")
	var scale_y: float = float(image.get_height()) / ProjectSettings.get_setting("display/window/size/viewport_height")

	var player_viewport_pos: Vector2 = Globals.player.get_global_transform_with_canvas().get_origin() * Vector2(scale_x, scale_y)
	var size: Vector2 = Vector2(60 * scale_x, 32 * scale_y)
	var image_fragment: Image = Image.create(size.x, size.y, image.has_mipmaps(), image.get_format())
	image_fragment.blit_rect(image, Rect2(player_viewport_pos.x - size.x/2.0, player_viewport_pos.y - size.y/2.0, size.x, size.y), Vector2.ZERO)
	#image.crop(size.x, size.y)
	cropped_viewport_texture = ImageTexture.create_from_image(image_fragment)

	color_rect.show()
	tab_container.show()
	seed_label.show()
	get_tree().paused = true


func hide_tab_container() -> void:
	color_rect.hide()
	tab_container.hide()
	seed_label.hide()
	get_tree().paused = false
