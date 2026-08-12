extends Node

## Autoload singleton: TimeManager
## Add as Autoload named "TimeM" in Project Settings.
## Drives the day counter that Farm/Monster systems listen to.

signal day_started(day_number: int)

var current_day: int = 1


func next_day() -> void:
	current_day += 1
	day_started.emit(current_day)
	# Farm.gd and Monster.gd should connect to this signal to:
	# - grow crops one stage
	# - regenerate monster products
	# - reset tavern customer state
