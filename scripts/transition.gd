extends CanvasLayer

const ThroughNightScene: PackedScene = preload("res://scenes/through_night.tscn")

@onready var color_rect = $ColorRect

## Guards against K/P being spammed mid-transition (stacking multiple
## fades) — shared by both play_day_end_transition() and
## play_skip_to_quota_day_transition() so they can't overlap each other.
var _is_playing_night_transition: bool = false

func _ready():
	color_rect.modulate.a = 0.0

func fade_to_scene(scene_path: String, duration: float = 0.5):
	# Fade to black
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, duration)
	await tween.finished
	
	# เปลี่ยนฉาก
	get_tree().change_scene_to_file(scene_path)
	
	# Fade กลับมาโปร่งใส
	var tween2 = create_tween()
	tween2.tween_property(color_rect, "modulate:a", 0.0, duration)
	await tween2.finished


## Fades in the through_night video over the current scene, calls
## TimeM.next_day() once fully covered, holds for hold_duration seconds,
## then fades back out. Used when the player presses K to skip/end the day.
func play_day_end_transition(fade_duration: float = 0.6, hold_duration: float = 3.0) -> void:
	if _is_playing_night_transition:
		return
	_is_playing_night_transition = true

	var night: Control = ThroughNightScene.instantiate()
	night.modulate.a = 0.0
	add_child(night)

	var fade_in := create_tween()
	fade_in.tween_property(night, "modulate:a", 1.0, fade_duration)
	await fade_in.finished

	TimeM.next_day()

	await get_tree().create_timer(hold_duration).timeout

	var fade_out := create_tween()
	fade_out.tween_property(night, "modulate:a", 0.0, fade_duration)
	await fade_out.finished

	night.queue_free()
	_is_playing_night_transition = false


## Fades in the through_night video, fast-forwards TimeM.next_day() from
## the current day up to Quota.due_day() (all under cover of the fade, so
## crop growth/monster regen still tick correctly for every skipped day),
## holds briefly, then fades back out. Used when the player presses P to
## jump straight to the current quota's deadline. No-op if the player is
## already at or past the due day.
func play_skip_to_quota_day_transition(fade_duration: float = 0.6, hold_duration: float = 1.5) -> void:
	if _is_playing_night_transition:
		return

	var target_day: int = Quota.due_day()
	if target_day <= TimeM.current_day:
		return

	_is_playing_night_transition = true

	var night: Control = ThroughNightScene.instantiate()
	night.modulate.a = 0.0
	add_child(night)

	var fade_in := create_tween()
	fade_in.tween_property(night, "modulate:a", 1.0, fade_duration)
	await fade_in.finished

	while TimeM.current_day < target_day:
		TimeM.next_day()

	await get_tree().create_timer(hold_duration).timeout

	var fade_out := create_tween()
	fade_out.tween_property(night, "modulate:a", 0.0, fade_duration)
	await fade_out.finished

	night.queue_free()
	_is_playing_night_transition = false
