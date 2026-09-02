extends CanvasModulate

## Attach to a CanvasModulate node (tints the whole 2D scene at once).
## Adapted from godot-tutorials-godot-4.x/day-night-cycle: instead of
## tracking its own clock, this listens to TimeM's existing time_changed
## signal (hour/minute) so there's only one source of truth for time.
##
## Maps the current hour/minute to a 0..1 "brightness" value via a sine
## curve (0 = midnight, 1 = noon), then samples gradient_texture at that
## point. The sine mapping is symmetric around noon/midnight, so the
## SAME gradient arc is reused for both the dawn (night->day) and dusk
## (day->night) transitions — only night-to-day needs designing.

@export var gradient_texture: GradientTexture1D


func _ready() -> void:
	TimeM.time_changed.connect(_on_time_changed)
	_on_time_changed(TimeM.hour, int(TimeM.minute))


func _on_time_changed(hour: int, minute: int) -> void:
	if gradient_texture == null:
		return
	var total_minutes: float = hour * 60.0 + minute
	var angle: float = (total_minutes / 1440.0) * TAU
	var value: float = (sin(angle - PI / 2.0) + 1.0) / 2.0
	self.color = gradient_texture.gradient.sample(value)
