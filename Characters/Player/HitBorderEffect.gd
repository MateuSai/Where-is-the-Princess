class_name HitBorderEffect extends NinePatchRect

enum Type { HP, ARMOR }

const HP_COLOR: Color = Color.RED
const ARMOR_COLOR: Color = Color("394879")


func _ready() -> void:
	hide()


func effect(type: Type, time: float) -> void:
	modulate = [HP_COLOR, ARMOR_COLOR][type]
	modulate.a = 1.0
	show()
	await create_tween().tween_property(self, "modulate:a", 0.0, time).finished
	hide()
