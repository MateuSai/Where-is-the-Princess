class_name WeaponUnlockedNotification extends PanelContainer

@onready var icon: TextureRect = %Icon
@onready var title: Label = %Title
@onready var description: Label = %Description


func initialize(arguments: Dictionary) -> void:
	icon.texture = arguments.data.icon

	title.text = tr("WEAPON_UNLOCKED_NOTIFICATION_TITLE") % tr(arguments.id.to_upper())
	description.text = tr("WEAPON_UNLOCKED_NOTIFICATION_DESCRIPTION") % tr(arguments.id.to_upper())
