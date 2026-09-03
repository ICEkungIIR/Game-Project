extends Camera2D

@export var zoom_step: float = 0.1
@export var min_zoom: float = 0.5
@export var max_zoom: float = 3.0
@export var zoom_lerp_speed: float = 8.0

var target_zoom: Vector2 = Vector2(1, 1)

func _ready() -> void:
	target_zoom = zoom

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_out"):
		zoom_camera(zoom_step)   # ซูมออก
	elif event.is_action_pressed("zoom_in"):
		zoom_camera(-zoom_step)  # ซูมเข้า

func zoom_camera(amount: float) -> void:
	var new_zoom_value = clamp(target_zoom.x + amount, min_zoom, max_zoom)
	target_zoom = Vector2(new_zoom_value, new_zoom_value)

func _process(delta: float) -> void:
	zoom = zoom.lerp(target_zoom, zoom_lerp_speed * delta)
