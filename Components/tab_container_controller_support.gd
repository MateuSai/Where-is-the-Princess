class_name TabContainerControllerSupport extends Node

var l_hint: Node2D
var r_hint: Node2D

@onready var tab_container: TabContainer = get_parent()


func _ready() -> void:
#	await tab_container.ready

	tab_container.draw.connect(_on_draw)
	tab_container.hidden.connect(_on_hide)

	set_process_input(false)

	if l_hint:
		l_hint.free()
	if r_hint:
		r_hint.free()

	l_hint = Node2D.new()
	r_hint = Node2D.new()
	for hint: Node2D in [l_hint, r_hint]:
		#hint = Node2D.new()
		hint.z_index = 10
		var texture_rect: TextureRect = TextureRect.new()
		texture_rect.name = "TextureRect"
		texture_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		var atlas_texture: AtlasTexture = AtlasTexture.new()
		atlas_texture.atlas = preload("res://Art/kenney_input-prompts-pixel-16/Tilemap/tilemap_packed.png")
		texture_rect.texture = atlas_texture
		texture_rect.size = Vector2(28, 28)

		hint.add_child(texture_rect)
		tab_container.call_deferred("add_child", hint)


func _on_draw() -> void:
	# print("_on_draw_called")
	if not Globals.mode_changed.is_connected(_update_controller_hints):
		# warning-ignore:return_value_discarded
		Globals.mode_changed.connect(_update_controller_hints)
	_update_controller_hints(Globals.mode)

	set_process_input(true)


func _on_hide() -> void:
	if Globals.mode_changed.is_connected(_update_controller_hints):
		Globals.mode_changed.disconnect(_update_controller_hints)

	set_process_input(false)


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
		if (event as InputEventJoypadButton).pressed:
			if (event as InputEventJoypadButton).button_index == JOY_BUTTON_LEFT_SHOULDER:
				_change_tab(-1)
			elif (event as InputEventJoypadButton).button_index == JOY_BUTTON_RIGHT_SHOULDER:
				_change_tab(1)


func _change_tab(dir: int) -> void:
	tab_container.current_tab = wrapi(tab_container.current_tab + dir, 0, tab_container.get_tab_count())

#	var control: Control = tab_container.get_child(tab_container.current_tab)
	# warning-ignore:return_value_discarded
#	_search_for_focus_control(control)


func _put_hints_on_correct_position() -> void:
	l_hint.position = Vector2(2, -30)
	r_hint.position = Vector2(tab_container.size.x - 30, -30)


#func _search_for_focus_control(control: Control) -> Control:
#	return null
#	#print(control.name)
#	for child in control.get_children():
#		if not child is Control:
#			continue
#
#		if child.focus_mode == Control.FOCUS_ALL:
#			child.grab_focus()
#			return child
#
#		var search: Control = _search_for_focus_control(child)
#		if search:
#			return search
#
#	return null


func _update_controller_hints(new_mode: int) -> void:
	if new_mode == Globals.Mode.MOUSE:
		l_hint.hide()
		r_hint.hide()
	else: # new_mode == CONTROLLER
		l_hint.show()
		r_hint.show()
		_put_hints_on_correct_position()
#		var control: Control = tab_container.get_child(tab_container.current_tab)
		# warning-ignore:return_value_discarded
#		_search_for_focus_control(control) # para que agarre focus
		var l_hint_atlas_texture: AtlasTexture = ((l_hint.get_node("TextureRect") as TextureRect).texture as AtlasTexture)
		var r_hint_atlas_texture: AtlasTexture = ((r_hint.get_node("TextureRect") as TextureRect).texture as AtlasTexture)
		match Globals.controller_type:
			Globals.CONTROLLER_TYPES.PS:
				l_hint_atlas_texture.region = Globals.INPUT_IMAGE_RECTS.ps_joypad_button_4 # L1
				r_hint_atlas_texture.region = Globals.INPUT_IMAGE_RECTS.ps_joypad_button_5 # R1
			_:
				l_hint_atlas_texture.region = Globals.INPUT_IMAGE_RECTS.xbox_joypad_button_4 # LB
				r_hint_atlas_texture.region = Globals.INPUT_IMAGE_RECTS.xbox_joypad_button_5 # RB
