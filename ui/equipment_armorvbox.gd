class_name EquipmentArmorVBox extends VBoxContainer


@onready var atlas_texture: AtlasTexture = %ArmorTexture.texture
#@onready var armor_name_label: Label = %ArmorNameLabel
#@onready var armor_description_label: Label = %ArmorDescriptionLabel


func _ready() -> void:
	draw.connect(_on_draw)


func _on_draw() -> void:
	var current_armor: Armor = Globals.player.armor

	#%ArmorTexture.texture = %UI.cropped_viewport_texture
	%ArmorTexture.texture = current_armor.get_icon()
	#atlas_texture.atlas = current_armor.sprite_sheet
	#armor_name_label.text = current_armor.get_armor_name()
	#armor_description_label.text = current_armor.get_description()
