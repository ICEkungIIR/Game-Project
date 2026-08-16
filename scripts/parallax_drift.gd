extends ParallaxBackground

## Speed of automatic horizontal drift (pixels/sec at motion_scale = 1.0)
@export var drift_speed: float = 3.0

func _process(delta: float) -> void:
	scroll_offset.x += drift_speed * delta
