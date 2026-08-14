extends Node2D

## Pulsing square outline showing which tile a tool action would target.
## Position/visibility are driven every frame by player.gd — this script
## only handles the glow animation and drawing.

@export var square_size: Vector2 = Vector2(16, 16)
@export var glow_color: Color = Color(1.0, 1.0, 0.6, 0.9)

var _t: float = 0.0


func _process(delta: float) -> void:
	if not visible:
		return
	_t += delta
	queue_redraw()


func _draw() -> void:
	var pulse: float = 0.5 + 0.5 * sin(_t * 4.0)
	var c: Color = glow_color
	c.a = lerp(0.35, 0.85, pulse)
	var half: Vector2 = square_size / 2.0
	draw_rect(Rect2(-half, square_size), c, false, 2.0)
