class_name SpriteWithRunStatsArmorSpritesheet extends Sprite2D

func _ready() -> void:
	if SavedData.run_stats.armor:
		texture = SavedData.run_stats.armor.get_sprite_sheet()
