extends Node

## Autoload singleton: TimeManager
## Add as Autoload named "TimeM" in Project Settings.
## Drives the day counter that Farm/Monster systems listen to, plus an
## in-day clock (hour/minute) for the time_HUD display and future
## day-night cycle work.

signal day_started(day_number: int)
signal time_changed(hour: int, minute: int)

var current_day: int = 1
var hour: int = 6
var minute: int = 0

## In-game minutes that pass per real second. Tune to taste.
@export var minutes_per_real_second: float = 1.0


func _process(delta: float) -> void:
	minute += minutes_per_real_second * delta
	if minute >= 60.0:
		minute = fmod(minute, 60.0)
		hour += 1
		if hour >= 24:
			hour = 0
			next_day()
	time_changed.emit(hour, int(minute))


func next_day() -> void:
	current_day += 1
	day_started.emit(current_day)
	# Farm.gd and Monster.gd should connect to this signal to:
	# - grow crops one stage
	# - regenerate monster products
	# - reset tavern customer state
