class_name AchievementUnlockedNotification extends PanelContainer

@onready var icon: TextureRect = %Icon
@onready var title: Label = %Title
@onready var description: Label = %Description

func initialize(arguments: Dictionary) -> void:
	icon.texture = arguments.icon

	title.text = arguments.id.to_upper()
	description.text = arguments.id.to_upper() + "_DESCRIPTION"
