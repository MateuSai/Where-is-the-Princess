class_name MenuTabContainer extends TabContainer

const GREY_ICONS: PackedStringArray = ["res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Pause_tab_MAP_unselected.png", "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Pause_tab_EQUIPMENT_unselected.png", "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Pause_tab_ENCYCLOPEDIA_unselected.png", "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Pause_tab_MENU_unselected.png"]
const COLOR_ICONS: PackedStringArray = ["res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Pause_tab_MAP_selected.png","res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Pause_tab_EQUIPMENT_selected.png","res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Pause_tab_ENCYCLOPEDIA_selected.png", "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Pause_tab_MENU_selected.png"]


func _ready() -> void:
	assert(GREY_ICONS.size() == get_tab_count())
	assert(COLOR_ICONS.size() == get_tab_count())

	for tab: int in get_tab_count():
		if tab == current_tab:
			set_tab_icon(tab, load(COLOR_ICONS[tab]) as Texture2D)
		else:
			set_tab_icon(tab, load(GREY_ICONS[tab]) as Texture2D)
			set_tab_title(tab, "")

	tab_changed.connect(func(tab: int) -> void:
		#print(get_previous_tab())
		#print(tab)

		set_tab_icon(get_previous_tab(), load(GREY_ICONS[get_previous_tab()]) as Texture2D)
		set_tab_title(get_previous_tab(), "")

		set_tab_icon(tab, load(COLOR_ICONS[tab]) as Texture2D)
		set_tab_title(tab, get_child(tab).name)
	)
