class_name Encyclopedia extends MarginContainer

enum {
	WEAPONS,
	ARMORS,
	ITEMS,
	ENEMIES,
	BIOMES,
}
var last_category: int = -1

@onready var category_buttons: VBoxContainer = %CategoryButtons
@onready var list_container: MarginContainer = $HBoxContainer/HBoxContainer/PanelContainer/MarginContainer/ScrollContainer/MarginContainer
@onready var details_scroll_container: ScrollContainer = %DetailsScrollContainer
@onready var details_vbox: VBoxContainer = %DetailsVBoxContainer

func _ready() -> void:
	for button: Button in category_buttons.get_children():
		assert(button is Button)
		button.pressed.connect(func() -> void: _set_category(button.get_index()))

	_set_category(WEAPONS)

func _draw() -> void:
	_set_category(last_category)

func _set_category(new_category: int) -> void:
	if last_category != - 1:
		(category_buttons.get_child(last_category) as Button).button_pressed = false
		#(category_buttons.get_child(last_category) as Button).z_index = 0
	last_category = new_category
	(category_buttons.get_child(last_category) as Button).button_pressed = true
	#(category_buttons.get_child(last_category) as Button).z_index = 1

	for i: int in range(list_container.get_child_count() - 1, -1, -1):
		list_container.get_child(i).free()

	match new_category:
		WEAPONS:
			var flow_container: HFlowContainer = HFlowContainer.new();

			var weapons_statistics: Dictionary = SavedData.statistics.get_weapons_statistics()
			var discovered_weapon_paths: PackedStringArray = SavedData.get_discovered_weapon_paths()
			for weapon_path: String in SavedData.get_all_weapon_paths():
				var weapon_data: WeaponData = Weapon.get_data(weapon_path)
				var button: Button = Button.new()
				button.icon = weapon_data.prop
				if not discovered_weapon_paths.has(weapon_path):
					button.modulate = Color.BLACK
					button.disabled = true
				else:
					button.pressed.connect(func() -> void:
						_clear_details()
						var weapon_id: String=Weapon.get_id_from_path(weapon_path)
						_show_weapon_details(weapon_id, weapon_path, weapon_data, weapons_statistics[weapon_id] if weapons_statistics.has(weapon_id) else null)
					)
				flow_container.add_child(button)

			list_container.add_child(flow_container)
		ARMORS:
			var flow_container: HFlowContainer = HFlowContainer.new()

			var discovered_armor_paths: PackedStringArray = ["res://Armors/underpants.gd"]
			discovered_armor_paths.append_array(SavedData.get_discovered_armors_paths())
			var all_armors: PackedStringArray = ["res://Armors/underpants.gd"]
			all_armors.append_array(SavedData.get_all_armor_paths())
			for armor_path: String in all_armors:
				var armor: Armor = load(armor_path).new()
				var button: Button = Button.new()
				button.icon = armor.get_icon()
				if not discovered_armor_paths.has(armor_path):
					button.modulate = Color.BLACK
					button.disabled = true
				else:
					button.pressed.connect(func() -> void:
						_clear_details()
						_show_armor_details(armor)
					)
				flow_container.add_child(button)

			list_container.add_child(flow_container);
		ITEMS:
			var vbox: VBoxContainer = VBoxContainer.new()

			var consumable_items_label: Label = Label.new()
			consumable_items_label.text = "CONSUMABLES"
			vbox.add_child(consumable_items_label)

			vbox.add_child(_create_items_flow_container(Data.ALL_VANILLA_CONSUMABLE_ITEMS))

			var passive_items_label: Label = Label.new()
			passive_items_label.text = "PASSIVE"
			vbox.add_child(passive_items_label)

			vbox.add_child(_create_items_flow_container(SavedData.get_all_items_paths()))

			var weapon_modifiers_label: Label = Label.new()
			weapon_modifiers_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			weapon_modifiers_label.text = "WEAPON_MODIFIERS"
			vbox.add_child(weapon_modifiers_label)

			vbox.add_child(_create_items_flow_container(Data.ALL_VANILLA_WEAPON_MODIFIERS))

			list_container.add_child(vbox)
		ENEMIES:
			var flow_container: HFlowContainer = HFlowContainer.new()

			for enemy_id: String in Globals.ENEMIES.keys():
				flow_container.add_child(_create_enemy_button(enemy_id))

			list_container.add_child(flow_container);
		BIOMES:
			var vbox: VBoxContainer = VBoxContainer.new()

			for biome: String in Data.ALL_VANILLA_BIOMES:
				var biome_conf: BiomeConf = SavedData.get_biome_by_id_or_path(biome)

				var button: Button = Button.new()
				button.custom_minimum_size.y = 48
				button.clip_contents = true
				#button.icon = load(biome_conf.encyclopedia_background)
				#button.expand_icon = true
				vbox.add_child(button)

				var margin_container: MarginContainer = MarginContainer.new()
				margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
				margin_container.add_theme_constant_override("margin_left", 4)
				margin_container.add_theme_constant_override("margin_top", 4)
				margin_container.add_theme_constant_override("margin_right", 4)
				margin_container.add_theme_constant_override("margin_bottom", 4)
				button.add_child(margin_container)

				# What the fuck is this? I wish I knew, for some reason a second margin container is necessary
				var second_margin_container: MarginContainer = MarginContainer.new()
				second_margin_container.clip_contents = true
				margin_container.add_child(second_margin_container)

				var tex: TextureRect = TextureRect.new()
				tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				tex.stretch_mode = TextureRect.STRETCH_KEEP
				tex.texture = load(biome_conf.encyclopedia_background)
				second_margin_container.add_child(tex)

				var biome_statistics: BiomeStatistics = SavedData.statistics.get_biome_statistics(biome_conf.name)
				if biome_statistics:
					button.pressed.connect(func() -> void:
						_clear_details()
						_show_biome_details(biome_conf)
					)
				else:
					button.modulate = Color.BLACK.lightened(0.3)
					button.disabled = true

			list_container.add_child(vbox)

func _clear_details() -> void:
	for i: int in range(details_vbox.get_child_count() - 1, -1, -1):
		details_vbox.get_child(i).free()

	details_scroll_container.scroll_vertical = 0

func _show_weapon_details(id: String, weapon_path: String, data: WeaponData, statistics: WeaponStatistics) -> void:
	if not statistics:
		statistics = WeaponStatistics.new()

	#var weapon_texture: TextureRect = TextureRect.new()
	#weapon_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	#weapon_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	#weapon_texture.custom_minimum_size.y = 64
	#weapon_texture.texture = data.prop
	#details_vbox.add_child(weapon_texture)

	var player_attacking_representation: PlayerAttackingRepresentation = load("res://ui/player_attacking_representation/player_attacking_representation.tscn").instantiate()
	details_vbox.add_child(player_attacking_representation)
	player_attacking_representation.initialize(weapon_path)

	var name_label: Label = Label.new()
	name_label.custom_minimum_size.x = details_vbox.size.x - 16
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.text = id.to_upper()
	details_vbox.add_child(name_label)

	var type_label: Label = Label.new()
	type_label.theme = load("res://SmallFontTheme.tres")
	type_label.custom_minimum_size.x = details_vbox.size.x - 16
	type_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	type_label.text = tr(WeaponData.Type.keys()[data.type])
	if data.subtype:
		type_label.text += " / " + tr(WeaponData.Subtype.keys()[data.subtype])
	details_vbox.add_child(type_label)

	var kills_label: Label = Label.new()
	kills_label.theme = load("res://SmallFontTheme.tres")
	kills_label.custom_minimum_size.x = details_vbox.size.x - 16
	kills_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	kills_label.text = tr("KILLS") + ": " + str(statistics.enemies_killed)
	details_vbox.add_child(kills_label)

func _show_armor_details(armor: Armor) -> void:
	var top_hbox: HBoxContainer = HBoxContainer.new()
	var left_vbox: VBoxContainer = VBoxContainer.new()
	top_hbox.add_child(left_vbox)

	var ability_icon: TextureRect = TextureRect.new()
	ability_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	ability_icon.texture = armor.ability_icon if armor.ability_icon else load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/armor_no_ability.png")
	left_vbox.add_child(ability_icon)

	var condition_hbox: HBoxContainer = HBoxContainer.new()
	condition_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	condition_hbox.add_theme_constant_override("separation", -1)
	left_vbox.add_child(condition_hbox)

	var armor_amount_label: Label = Label.new()
	armor_amount_label.text = str(armor.max_condition)
	condition_hbox.add_child(armor_amount_label)

	var armor_condition_icon: TextureRect = TextureRect.new()
	armor_condition_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	armor_condition_icon.texture = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/items/armor_shard.png")
	condition_hbox.add_child(armor_condition_icon)

	var armor_texture: TextureRect = TextureRect.new()
	armor_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	armor_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	armor_texture.custom_minimum_size.y = 64
	var atlas: AtlasTexture = AtlasTexture.new()
	atlas.atlas = armor.get_sprite_sheet()
	atlas.region = Rect2(0, 0, 16, 16)
	armor_texture.texture = atlas
	top_hbox.add_child(armor_texture)

	details_vbox.add_child(top_hbox)

	var name_label: Label = Label.new()
	name_label.custom_minimum_size.x = details_vbox.size.x - 16
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.text = armor.get_armor_name()
	details_vbox.add_child(name_label)

	var description_label: Label = Label.new()
	description_label.theme = load("res://SmallFontTheme.tres")
	description_label.custom_minimum_size.x = details_vbox.size.x - 16
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.text = armor.get_description()
	details_vbox.add_child(description_label)

func _show_item_details(item: Item, statistics: ItemStatistics) -> void:
	var item_texture: TextureRect = TextureRect.new()
	item_texture.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	item_texture.stretch_mode = TextureRect.STRETCH_KEEP
	if item.get_big_icon():
		item_texture.texture = item.get_big_icon()
	else:
		push_warning("No big icon found, using small one")
		item_texture.texture = item.get_icon()
	details_vbox.add_child(item_texture)

	var name_label: Label = Label.new()
	name_label.custom_minimum_size.x = details_vbox.size.x - 16
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.text = item.get_item_name()
	details_vbox.add_child(name_label)

	var description_label: Label = Label.new()
	description_label.theme = load("res://SmallFontTheme.tres")
	description_label.custom_minimum_size.x = details_vbox.size.x - 16
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.text = item.get_item_description()
	details_vbox.add_child(description_label)

	var times_picked_up_label: Label = Label.new()
	times_picked_up_label.theme = load("res://SmallFontTheme.tres")
	times_picked_up_label.custom_minimum_size.x = details_vbox.size.x - 16
	times_picked_up_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	times_picked_up_label.text = tr("TIMES_PICKED_UP") + ": " + str(statistics.times_picked_up)
	details_vbox.add_child(times_picked_up_label)

func _show_enemy_details(id: String, data: EnemyData, statistics: EnemyStatistics) -> void:
	if not statistics:
		statistics = EnemyStatistics.new()

	var biome_background: TextureRect = TextureRect.new()
	biome_background.clip_contents = true
	biome_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	biome_background.stretch_mode = TextureRect.STRETCH_KEEP
	biome_background.texture = load(SavedData.get_biome_by_id_or_path(data.biomes[0]).encyclopedia_background)
	biome_background.custom_minimum_size.y = 64
	details_vbox.add_child(biome_background)

	#var ability_icon: TextureRect = TextureRect.new()
	#ability_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	#ability_icon.texture = armor.ability_icon if armor.ability_icon else load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/armor_no_ability.png")
	#left_vbox.add_child(ability_icon)

	var center_container: CenterContainer = CenterContainer.new()
	center_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	biome_background.add_child(center_container)

	var enemy_texture: TextureRect = TextureRect.new()
	enemy_texture.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	enemy_texture.stretch_mode = TextureRect.STRETCH_KEEP
	enemy_texture.texture = data.icon
	enemy_texture.size = enemy_texture.texture.get_size()
	center_container.add_child(enemy_texture)
	#enemy_texture.pivot_offset = enemy_texture.texture.get_size() / 2
	#enemy_texture.anchor_left = 0.5
	#enemy_texture.anchor_top = 0.5
	#enemy_texture.anchor_right = 0.5
	#enemy_texture.anchor_bottom = 0.5
	#enemy_texture.layout_mode = 1 # Anchors
	#enemy_texture.set_anchors_preset(Control.PRESET_CENTER)
	#enemy_texture.offset_left = 0
	#enemy_texture.offset_right = 0
	#enemy_texture.offset_bottom = 0
	#enemy_texture.offset_top = 0

	var hearts_hflow: HFlowContainer = HFlowContainer.new()
	hearts_hflow.add_theme_constant_override("h_separation", 0)
	var full_hearts: int = floor(data.max_hp / 4.0)
	for i: int in full_hearts:
		var texture_rect: TextureRect = TextureRect.new()
		texture_rect.texture = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart smol anim_01.png")
		hearts_hflow.add_child(texture_rect)
	if data.max_hp % 4 in [1, 2, 3]:
			var texture_rect: TextureRect = TextureRect.new()
			texture_rect.texture = load("res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Heart fraction anims/Heart_smol_" + str(data.max_hp % 4) + "-4_anim_01.png")
			hearts_hflow.add_child(texture_rect)
	details_vbox.add_child(hearts_hflow)

	var name_label: Label = Label.new()
	name_label.custom_minimum_size.x = details_vbox.size.x - 16
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.text = id.to_upper()
	details_vbox.add_child(name_label)

	var biome_label: Label = Label.new()
	biome_label.theme = load("res://SmallFontTheme.tres")
	biome_label.custom_minimum_size.x = details_vbox.size.x - 16
	biome_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	biome_label.text = tr("BIOMES") + ": "
	assert(data.biomes.size() > 0)
	for biome: String in data.biomes:
		var biome_conf: BiomeConf = SavedData.get_biome_by_id_or_path(biome)
		biome_label.text += tr(biome_conf.name) + ", "
	biome_label.text = biome_label.text.trim_suffix(", ")
	details_vbox.add_child(biome_label)

	var description_label: Label = Label.new()
	description_label.theme = load("res://SmallFontTheme.tres")
	description_label.custom_minimum_size.x = details_vbox.size.x - 16
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.text = id.to_upper() + "_DESCRIPTION"
	details_vbox.add_child(description_label)

	var killed_label: Label = Label.new()
	killed_label.theme = load("res://SmallFontTheme.tres")
	killed_label.custom_minimum_size.x = details_vbox.size.x - 16
	killed_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	killed_label.text = tr("TIMES_KILLED") + ": " + str(statistics.times_killed)
	details_vbox.add_child(killed_label)

	var player_kills_label: Label = Label.new()
	player_kills_label.theme = load("res://SmallFontTheme.tres")
	player_kills_label.custom_minimum_size.x = details_vbox.size.x - 16
	player_kills_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	player_kills_label.text = tr("PLAYER_KILLS") + ": " + str(statistics.player_kills)
	details_vbox.add_child(player_kills_label)

func _show_biome_details(conf: BiomeConf) -> void:
	var name_label: Label = Label.new()
	name_label.custom_minimum_size.x = details_vbox.size.x - 16
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.text = conf.name
	details_vbox.add_child(name_label)

	var biome_background: TextureRect = TextureRect.new()
	biome_background.clip_contents = true
	biome_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	biome_background.stretch_mode = TextureRect.STRETCH_KEEP
	biome_background.texture = load(conf.encyclopedia_background)
	biome_background.custom_minimum_size.y = 64
	details_vbox.add_child(biome_background)

	var enemies_hflow: HFlowContainer = HFlowContainer.new()
	for enemy_id: String in Globals.ENEMIES.keys():
		var enemy_data: EnemyData = Enemy.get_data(enemy_id)
		for biome: String in enemy_data.biomes:
			if SavedData.get_biome_by_id_or_path(biome).name == conf.name:
				var button: Button = _create_enemy_button(enemy_id)
				#button.flat = true
				enemies_hflow.add_child(button)
				#var tex: TextureRect = TextureRect.new()
				#tex.texture = enemy_data.icon
				#tex.expand_mode = TextureRect.EXPAND_KEEP_SIZE
				#tex.stretch_mode = TextureRect.STRETCH_KEEP
				#enemies_hflow.add_child(tex)
				break
	details_vbox.add_child(enemies_hflow)

func _create_items_flow_container(items: PackedStringArray) -> HFlowContainer:
	var flow_container: HFlowContainer = HFlowContainer.new()

	for item_path: String in items:
		var item: Item = load(item_path).new()
		var statistics: ItemStatistics = SavedData.statistics.get_item_statistics(item.get_id())
		var button: Button = Button.new()
		button.icon = item.get_icon()
		if statistics == null:
			button.modulate = Color.BLACK
			button.disabled = true
		else:
			button.pressed.connect(func() -> void:
				_clear_details()
				_show_item_details(item, statistics)
			)
		flow_container.add_child(button)

	return flow_container

func _create_enemy_button(enemy_id: String) -> Button:
	var enemy_data: EnemyData = Enemy.get_data(enemy_id)
	var enemy_statistics: EnemyStatistics = SavedData.statistics.get_enemy_statistics(enemy_id)

	var button: Button = Button.new()
	#button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.icon = enemy_data.icon
	if not enemy_statistics:
		button.modulate = Color.BLACK
		button.disabled = true
	else:
		button.pressed.connect(func() -> void:
			_clear_details()
			_show_enemy_details(enemy_id, enemy_data, enemy_statistics)
		, CONNECT_DEFERRED)

	return button
