extends Button

func _ready() -> void:
	pivot_offset = size / 2.0
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)

func _on_hover() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.15)

func _on_unhover() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
