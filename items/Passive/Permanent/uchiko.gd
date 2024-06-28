class_name Uchiko extends PermanentPassiveItem

func _init() -> void:
    effects = [
        IncreaseWeaponDegradationReduction.new(0.22)
    ]