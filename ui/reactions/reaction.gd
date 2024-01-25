class_name Reaction extends Control


@onready var face: TextureRect = %Face


enum {
	MAD,
	VERY_MAD,
}


func react(reaction: int) -> void:
	face.texture = load(["res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Reactions/enojado.png", "res://Art/16x16 Pixel Art Roguelike (Forest) Pack/ui/Reactions/furioso.png"][reaction])

	var tween: Tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(queue_free)
