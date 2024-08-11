class_name ItemsContainer extends HFlowContainer

var player: Player
var show_tooltip: bool

func _ready() -> void:
	if owner is Player:
		# Player ui
		player = owner
		show_tooltip = false
	else:
		# It means we are on the game menu
		await (get_tree().current_scene as Game).player_added
		player = Globals.player
		show_tooltip = true

		# Since we waited for the player to be ready, we missed the signals he emitted, so we iterate over the items and add them
		for item: PermanentArtifact in SavedData.run_stats.get_permanent_passive_items():
			_on_player_permanent_passive_item_picked_up(item)
		for item: TemporalArtifact in SavedData.run_stats.temporal_passive_items:
			_on_player_temporal_passive_item_picked_up(item)

	player.permanent_passive_item_picked_up.connect(_on_player_permanent_passive_item_picked_up)
	player.permanent_passive_item_unequiped.connect(_on_player_permanent_passive_item_unequiped)
	player.temporal_passive_item_picked_up.connect(_on_player_temporal_passive_item_picked_up)
	player.temporal_passive_item_unequiped.connect(_on_player_temporal_passive_item_unequiped)

func _on_player_permanent_passive_item_picked_up(item: PermanentArtifact) -> void:
	var texture_rect: ArtifactIcon = ArtifactIcon.new()
	texture_rect.show_tooltip = show_tooltip
	texture_rect.item = item
	texture_rect.texture = item.get_icon()
	var item_class_name: String = (item.get_script() as Script).get_path().get_file().trim_suffix(".gd")
	texture_rect.name = item_class_name
	add_child(texture_rect)

func _on_player_permanent_passive_item_unequiped(item: PermanentArtifact) -> void:
	(get_node((item.get_script() as Script).get_path().get_file().trim_suffix(".gd")) as ArtifactIcon).free()

func _on_player_temporal_passive_item_picked_up(item: TemporalArtifact) -> void:
	var item_class_name: String = (item.get_script() as Script).get_path().get_file().trim_suffix(".gd")
	var temporal_passive_item_icon: TemporalArtifactIcon = get_node_or_null(item_class_name)
	if temporal_passive_item_icon:
		temporal_passive_item_icon.add()
	else:
		temporal_passive_item_icon = TemporalArtifactIcon.new()
		temporal_passive_item_icon.show_tooltip = show_tooltip
		# print(item.get_script().get_path().get_file().trim_suffix(".gd"))
		temporal_passive_item_icon.name = item_class_name
		temporal_passive_item_icon.item = item
		temporal_passive_item_icon.texture = item.get_icon()
		add_child(temporal_passive_item_icon)

func _on_player_temporal_passive_item_unequiped(item: TemporalArtifact) -> void:
	(get_node((item.get_script() as Script).get_path().get_file().trim_suffix(".gd")) as TemporalArtifactIcon).remove()

class ArtifactIcon extends TextureRect:
	var item: Item

	var show_tooltip: bool = false:
		set(new_value):
			show_tooltip = new_value
			if show_tooltip:
				modulate.a = 1.0
			else:
				modulate.a = 0.6

	func _init() -> void:
		theme = load("res://SmallFontTheme.tres")
		modulate.a = 0.6

	#func _ready() -> void:
		process_mode = Node.PROCESS_MODE_WHEN_PAUSED

		#Globals.pause_menu_opened.connect(func() -> void:
			#z_index = 100
			#modulate.a = 1.0
			#pause_menu_open = true
		#)
		#Globals.pause_menu_closed.connect(func() -> void:
			#z_index = 0
			#modulate.a = 0.6
			#pause_menu_open = false
		#)
	func _ready() -> void:
		if show_tooltip:
			mouse_entered.connect(func() -> void:
				get_tree().current_scene.get_node("UI/InfoPanel").show_at(global_position + Vector2.RIGHT * size.x + Vector2.DOWN * size.y / 2, item)
			)
			mouse_exited.connect(func() -> void:
				get_tree().current_scene.get_node("UI/InfoPanel").stop_showing()
			)

	#func _get_tooltip(_at_position: Vector2) -> String:
		#if show_tooltip:
			#match item.get_quality():
				#Item.Quality.COMMON:
					#return tr(item.get_item_name()) + "\n\n" + tr(item.get_item_description())
				#Item.Quality.CHINGON:
					#return "[color=blue]" + tr(item.get_item_name()) + "[/color]\n\n" + tr(item.get_item_description())
				#_:
					#assert(false, "invalid type")
					#return ""
		#else:
			#return ""
#
	#func _make_custom_tooltip(for_text: String) -> Object:
		#var custom_tooltip: CustomTooltip = load("res://ui/custom_tooltip.tscn").instantiate()
#
		#var splitted_text: PackedStringArray = for_text.split("\n\n")
		#custom_tooltip.initialize(splitted_text[0], splitted_text[1])
#
		#return custom_tooltip

class TemporalArtifactIcon extends ArtifactIcon:
	var amount: int = 1

	var label: Label

	func _init() -> void:
		label = Label.new()
		label.theme = load("res://SmallFontTheme.tres")
		label.set_anchors_preset(Control.PRESET_TOP_LEFT)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.offset_left = 0
		label.offset_right = 0
		label.offset_bottom = 0
		label.offset_top = 0
		label.add_theme_font_size_override("font_size", 10)
		label.text = "1"
		add_child(label)

	func add() -> void:
		amount += 1
		label.text = str(amount)

	func remove() -> void:
		amount -= 1
		if amount == 0:
			queue_free()
		else:
			label.text = str(amount)
