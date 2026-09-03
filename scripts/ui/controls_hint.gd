extends Control

## Attach to controls_hint.tscn's root Control.
##
## Shows a black-text, gold-glowing reminder of the player's controls for a
## few seconds whenever world.tscn loads, then fades out and frees itself.
## The "glow" is a pulsing font outline (no shader needed) — outline_size
## oscillates between pulse_min_outline and pulse_max_outline.

@export var display_duration: float = 10.0
@export var fade_duration: float = 0.4
@export var glow_color: Color = Color(1.0, 0.82, 0.15)  # gold
@export var pulse_min_outline: float = 4.0
@export var pulse_max_outline: float = 10.0
@export var pulse_time: float = 1.1  # seconds for one outline min->max swing

@onready var label: Label = $Label

var _glow_tween: Tween


func _ready() -> void:
	modulate.a = 0.0
	label.add_theme_color_override("font_color", Color.BLACK)
	label.add_theme_color_override("font_outline_color", glow_color)
	label.add_theme_constant_override("outline_size", int(pulse_min_outline))
	label.add_theme_color_override("font_shadow_color", Color(glow_color, 0.6))
	label.add_theme_constant_override("shadow_outline_size", 6)

	_start_glow_pulse()

	var fade_in := create_tween()
	fade_in.tween_property(self, "modulate:a", 1.0, fade_duration)
	await fade_in.finished

	var hold_time: float = max(display_duration - fade_duration * 2.0, 0.0)
	await get_tree().create_timer(hold_time).timeout

	var fade_out := create_tween()
	fade_out.tween_property(self, "modulate:a", 0.0, fade_duration)
	await fade_out.finished

	if _glow_tween:
		_glow_tween.kill()
	queue_free()


func _start_glow_pulse() -> void:
	_glow_tween = create_tween()
	_glow_tween.set_loops()
	_glow_tween.tween_method(_set_outline_size, pulse_min_outline, pulse_max_outline, pulse_time)
	_glow_tween.tween_method(_set_outline_size, pulse_max_outline, pulse_min_outline, pulse_time)


func _set_outline_size(value: float) -> void:
	label.add_theme_constant_override("outline_size", int(round(value)))
