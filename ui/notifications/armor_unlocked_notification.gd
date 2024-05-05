class_name ArmorUnlockedNotification extends PanelContainer

@onready var icon: TextureRect = %Icon
@onready var title: Label = %Title
@onready var description: Label = %Description

func initialize(arguments: Dictionary) -> void:
	icon.texture = arguments.icon

	title.text = tr("ARMOR_UNLOCKED_NOTIFICATION_TITLE") % tr(arguments.id.to_upper())
	description.text = tr("ARMOR_UNLOCKED_NOTIFICATION_DESCRIPTION") % tr(arguments.id.to_upper())
