class_name HPBar extends TextureProgressBar

const SCALE: float = 5

var _tween: Tween

@onready var life_component: PlayerLifeComponent = owner.get_node("LifeComponent")

@onready var nine_patch: NinePatchRect = get_node("%HealthNinePatch")

func _ready() -> void:
	life_component.hp_changed.connect(_on_hp_changed)
	life_component.max_hp_changed.connect(_on_max_hp_changed)
	_on_max_hp_changed(life_component.max_hp)

func _on_hp_changed(new_hp: int) -> void:
		if is_instance_valid(_tween) and _tween.is_running():
			_tween.kill()
			_tween = null
		_tween = create_tween()
		#print(str(START_AT_VALUE + (new_condition/float(current_armor.max_condition))))
		#print(str(START_AT_VALUE + (new_condition/float(current_armor.max_condition)) * (100 - START_AT_VALUE)))
		_tween.tween_property(self, "value", new_hp, 0.8).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)

func _on_max_hp_changed(new_max_hp: int) -> void:
	max_value=new_max_hp
	nine_patch.custom_minimum_size.x=max_value * SCALE
